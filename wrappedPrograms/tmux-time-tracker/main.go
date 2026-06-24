// tmux-time-tracker records activity samples (UTC epoch time, the running
// program, the working directory, and the nearest enclosing git repository)
// to a SQLite database, and can report aggregated time spent per project.
//
// Subcommands:
//
//	record  - record a sample for the pane that triggered this invocation
//	          (the default if no subcommand is given). Intended to be run
//	          from tmux hooks.
//	report  - print a per-project breakdown of recorded time.
package main

import (
	"database/sql"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"time"

	_ "github.com/mattn/go-sqlite3"
)

const schema = `
CREATE TABLE IF NOT EXISTS activity (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	time INTEGER NOT NULL,
	program TEXT NOT NULL,
	cwd TEXT NOT NULL,
	git_dir TEXT NOT NULL
);
`

// maxIdleGap caps how much of the gap between two consecutive samples is
// attributed to the earlier sample's project in the report, so long
// stretches away from the keyboard aren't counted as active time.
const maxIdleGap = 30 * time.Minute

// dbPath returns the location of the SQLite database, honouring
// $TMUX_TIME_TRACKER_DB for overrides (used by tests) and falling back to
// $XDG_DATA_HOME/tmux-time-tracker/activity.db.
func dbPath() (string, error) {
	if p := os.Getenv("TMUX_TIME_TRACKER_DB"); p != "" {
		return p, nil
	}

	dataHome := os.Getenv("XDG_DATA_HOME")
	if dataHome == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		dataHome = filepath.Join(home, ".local", "share")
	}

	return filepath.Join(dataHome, "tmux-time-tracker", "activity.db"), nil
}

// openDB opens (creating if necessary) the SQLite database and ensures the
// activity table exists.
func openDB() (*sql.DB, error) {
	path, err := dbPath()
	if err != nil {
		return nil, err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return nil, err
	}

	db, err := sql.Open("sqlite3", path)
	if err != nil {
		return nil, err
	}

	if _, err := db.Exec(schema); err != nil {
		db.Close()
		return nil, err
	}
	return db, nil
}

// findGitDir walks up from dir looking for the nearest ancestor (inclusive)
// containing a .git entry, returning that directory as the project root.
// Returns "" if no enclosing git repository is found.
func findGitDir(dir string) string {
	for {
		if _, err := os.Stat(filepath.Join(dir, ".git")); err == nil {
			return dir
		}

		parent := filepath.Dir(dir)
		if parent == dir {
			return ""
		}
		dir = parent
	}
}

// tmuxDisplay runs `tmux display-message -p -F <format>` for the given pane
// (the active pane of the current session if target is empty) and returns
// the expanded format, with the trailing newline stripped.
func tmuxDisplay(target, format string) (string, error) {
	args := []string{"display-message", "-p"}
	if target != "" {
		args = append(args, "-t", target)
	}
	args = append(args, "-F", format)

	out, err := exec.Command("tmux", args...).Output()
	if err != nil {
		return "", fmt.Errorf("tmux display-message: %w", err)
	}
	return strings.TrimRight(string(out), "\n"), nil
}

// paneInfo asks tmux for the running program and cwd of the pane that
// triggered this invocation (via $TMUX_PANE, set by tmux for hook/run-shell
// commands), falling back to the active pane of the current session.
//
// The two values are fetched with separate display-message calls: tmux
// replaces literal control characters (e.g. a tab used as a field
// separator) with "_" when expanding a -F format, so a single
// "a\tb"-style format can't be split back apart reliably.
func paneInfo() (program, cwd string, err error) {
	target := os.Getenv("TMUX_PANE")

	program, err = tmuxDisplay(target, "#{pane_current_command}")
	if err != nil {
		return "", "", err
	}

	cwd, err = tmuxDisplay(target, "#{pane_current_path}")
	if err != nil {
		return "", "", err
	}

	return program, cwd, nil
}

// record inserts a single activity sample for the triggering pane.
func record() error {
	program, cwd, err := paneInfo()
	if err != nil {
		return err
	}

	db, err := openDB()
	if err != nil {
		return err
	}
	defer db.Close()

	_, err = db.Exec(
		"INSERT INTO activity (time, program, cwd, git_dir) VALUES (?, ?, ?, ?)",
		time.Now().UTC().Unix(), program, cwd, findGitDir(cwd),
	)
	return err
}

// formatDuration renders d as e.g. "2h15m", "15m30s" or "9s".
func formatDuration(d time.Duration) string {
	d = d.Round(time.Second)
	h := d / time.Hour
	d -= h * time.Hour
	m := d / time.Minute
	d -= m * time.Minute
	s := d / time.Second

	switch {
	case h > 0:
		return fmt.Sprintf("%dh%02dm", h, m)
	case m > 0:
		return fmt.Sprintf("%dm%02ds", m, s)
	default:
		return fmt.Sprintf("%ds", s)
	}
}

// report prints a per-project breakdown of recorded time, sorted by total
// time descending. The time attributed to a project is the sum of the gaps
// between consecutive samples whose project that gap follows (the gap after
// the final sample runs up to now), each capped at maxIdleGap.
func report(w io.Writer) error {
	db, err := openDB()
	if err != nil {
		return err
	}
	defer db.Close()

	rows, err := db.Query("SELECT time, cwd, git_dir FROM activity ORDER BY time ASC")
	if err != nil {
		return err
	}
	defer rows.Close()

	type sample struct {
		time    int64
		project string
	}

	var samples []sample
	for rows.Next() {
		var t int64
		var cwd, gitDir string
		if err := rows.Scan(&t, &cwd, &gitDir); err != nil {
			return err
		}
		project := gitDir
		if project == "" {
			project = cwd
		}
		samples = append(samples, sample{t, project})
	}
	if err := rows.Err(); err != nil {
		return err
	}

	totals := make(map[string]time.Duration)
	now := time.Now().UTC().Unix()
	for i, s := range samples {
		end := now
		if i+1 < len(samples) {
			end = samples[i+1].time
		}

		gap := time.Duration(end-s.time) * time.Second
		if gap < 0 {
			gap = 0
		}
		if gap > maxIdleGap {
			gap = maxIdleGap
		}
		totals[s.project] += gap
	}

	type projectTotal struct {
		project string
		total   time.Duration
	}
	projects := make([]projectTotal, 0, len(totals))
	for project, total := range totals {
		projects = append(projects, projectTotal{project, total})
	}
	sort.Slice(projects, func(i, j int) bool {
		return projects[i].total > projects[j].total
	})

	for _, p := range projects {
		fmt.Fprintf(w, "%s\t%s\n", formatDuration(p.total), p.project)
	}
	return nil
}

func main() {
	cmd := "record"
	if len(os.Args) > 1 {
		cmd = os.Args[1]
	}

	var err error
	switch cmd {
	case "record":
		err = record()
	case "report":
		err = report(os.Stdout)
	default:
		err = fmt.Errorf("unknown subcommand %q (want %q or %q)", cmd, "record", "report")
	}

	if err != nil {
		fmt.Fprintln(os.Stderr, "tmux-time-tracker:", err)
		os.Exit(1)
	}
}
