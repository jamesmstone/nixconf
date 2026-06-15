// tmux-time-tracker records a single activity sample (UTC epoch time,
// the running program, the working directory, and the nearest enclosing
// git repository) to a SQLite database. It is intended to be invoked from
// tmux hooks so that activity is logged on every pane focus / selection
// change.
package main

import (
	"database/sql"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
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

// paneInfo asks tmux for the running program and cwd of the pane that
// triggered this invocation (via $TMUX_PANE, set by tmux for hook/run-shell
// commands), falling back to the active pane of the current session.
func paneInfo() (program, cwd string, err error) {
	args := []string{"display-message", "-p"}
	if pane := os.Getenv("TMUX_PANE"); pane != "" {
		args = append(args, "-t", pane)
	}
	args = append(args, "-F", "#{pane_current_command}\t#{pane_current_path}")

	out, err := exec.Command("tmux", args...).Output()
	if err != nil {
		return "", "", fmt.Errorf("tmux display-message: %w", err)
	}

	parts := strings.SplitN(strings.TrimRight(string(out), "\n"), "\t", 2)
	if len(parts) != 2 {
		return "", "", fmt.Errorf("unexpected tmux display-message output: %q", out)
	}
	return parts[0], parts[1], nil
}

func run() error {
	program, cwd, err := paneInfo()
	if err != nil {
		return err
	}

	path, err := dbPath()
	if err != nil {
		return err
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return err
	}

	db, err := sql.Open("sqlite3", path)
	if err != nil {
		return err
	}
	defer db.Close()

	if _, err := db.Exec(schema); err != nil {
		return err
	}

	_, err = db.Exec(
		"INSERT INTO activity (time, program, cwd, git_dir) VALUES (?, ?, ?, ?)",
		time.Now().UTC().Unix(), program, cwd, findGitDir(cwd),
	)
	return err
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, "tmux-time-tracker:", err)
		os.Exit(1)
	}
}
