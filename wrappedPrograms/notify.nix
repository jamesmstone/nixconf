# Keyed off WAYLAND_DISPLAY to match `open`.
{
  perSystem = {pkgs, ...}: {
    packages.notify = pkgs.writeShellApplication {
      name = "notify";
      runtimeInputs = [pkgs.libnotify pkgs.tmux];
      text = ''
        title="''${1:-}"
        message="''${2:-}"
        urgency="''${3:-normal}"

        if [ -z "$title" ]; then
          echo "usage: notify <title> <message> [low|normal|critical]" >&2
          exit 2
        fi

        if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
          case "$urgency" in
            critical) style="#[fg=colour231,bg=colour196,blink,bold]"; duration=5000 ;;
            low)      style="#[fg=colour232,bg=colour40,bold]";        duration=2000 ;;
            *)        style="#[fg=colour232,bg=colour220,bold]";       duration=3000 ;;
          esac
          uid="$(id -u)"
          {
            [ -n "''${TMUX:-}" ]             && printf '%s\n' "''${TMUX%%,*}"
            [ -n "''${TMUX_TMPDIR:-}" ]      && printf '%s\n' "$TMUX_TMPDIR/tmux-$uid/default"
            [ -n "''${XDG_RUNTIME_DIR:-}" ]  && printf '%s\n' "$XDG_RUNTIME_DIR/tmux-$uid/default"
            printf '%s\n' "/tmp/tmux-$uid/default"
          } | awk 'NF && !seen[$0]++' | while IFS= read -r sock; do
            [ -S "$sock" ] || continue
            clients="$(tmux -S "$sock" list-clients -F '#{client_name}' 2>/dev/null || true)"
            [ -n "$clients" ] || continue
            printf '%s\n' "$clients" | while IFS= read -r client; do
              tmux -S "$sock" display-message -c "$client" -d "$duration" "$style $title: $message"
            done
          done
        else
          notify-send --urgency="$urgency" "$title" "$message"
        fi
      '';
    };
  };
}
