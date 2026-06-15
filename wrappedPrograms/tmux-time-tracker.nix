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
    # git_dir is resolved by walking up from cwd to the nearest `.git`.
    checks.tmux-time-tracker = let
      tracker = self'.packages.tmux-time-tracker;
      fakeTmux = pkgs.writeShellScriptBin "tmux" ''
        case "$*" in
          *display-message*) printf 'nvim\t%s/repo/src\n' "$TEST_ROOT" ;;
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

        tmux-time-tracker

        row=$(sqlite3 "$TMUX_TIME_TRACKER_DB" "SELECT program, cwd, git_dir FROM activity")
        expected="nvim|$TEST_ROOT/repo/src|$TEST_ROOT/repo"
        [ "$row" = "$expected" ] || { echo "unexpected row: $row (expected $expected)" >&2; exit 1; }

        ts=$(sqlite3 "$TMUX_TIME_TRACKER_DB" "SELECT time FROM activity")
        now=$(date -u +%s)
        diff=$((now - ts))
        [ "$diff" -ge 0 ] && [ "$diff" -lt 3600 ] || { echo "timestamp $ts not close to now $now" >&2; exit 1; }

        touch $out
      '';
  };
}
