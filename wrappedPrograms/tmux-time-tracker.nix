{
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.tmux-time-tracker = pkgs.buildGoModule {
      pname = "tmux-time-tracker";
      version = "0.1.0";
      src = ./tmux-time-tracker;
      vendorHash = null;
    };

    # Drives the binary with a fake `tmux` on PATH and checks the row it
    # writes to SQLite: program/cwd come from `tmux display-message`, and
    # git_dir is resolved by walking up from cwd to the nearest `.git`. Then
    # seeds an older sample for a second project and checks `report`'s
    # per-project aggregation and idle-gap capping (30m).
    checks.tmux-time-tracker = let
      tracker = self'.packages.tmux-time-tracker;
      fakeTmux = pkgs.writeShellScriptBin "tmux" ''
        case "$*" in
          *'#{pane_current_command}'*) printf 'nvim\n' ;;
          *'#{pane_current_path}'*) printf '%s/repo/src\n' "$TEST_ROOT" ;;
          *) exit 1 ;;
        esac
      '';
    in
      pkgs.runCommand "tmux-time-tracker-check" {
        nativeBuildInputs = [pkgs.sqlite tracker fakeTmux];
      } ''
        export TEST_ROOT=$PWD
        mkdir -p repo/src repo/.git
        export TMUX_PANE=%1
        export TMUX_TIME_TRACKER_DB=$PWD/activity.db

        tmux-time-tracker record

        row=$(sqlite3 "$TMUX_TIME_TRACKER_DB" "SELECT program, cwd, git_dir FROM activity")
        expected="nvim|$TEST_ROOT/repo/src|$TEST_ROOT/repo"
        [ "$row" = "$expected" ] || { echo "unexpected row: $row (expected $expected)" >&2; exit 1; }

        ts=$(sqlite3 "$TMUX_TIME_TRACKER_DB" "SELECT time FROM activity")
        now=$(date -u +%s)
        diff=$((now - ts))
        [ "$diff" -ge 0 ] && [ "$diff" -lt 3600 ] || { echo "timestamp $ts not close to now $now" >&2; exit 1; }

        sqlite3 "$TMUX_TIME_TRACKER_DB" \
          "INSERT INTO activity (time, program, cwd, git_dir) VALUES (1000, 'bash', '/projB', '/projB')"

        report=$(tmux-time-tracker report)
        echo "$report" | head -n1 | grep -qE '^30m00s[[:space:]]+/projB$' \
          || { echo "unexpected report order/format: $report" >&2; exit 1; }
        echo "$report" | grep -qF "$TEST_ROOT/repo" \
          || { echo "report missing current project: $report" >&2; exit 1; }

        touch $out
      '';
  };
}
