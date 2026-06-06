{
  perSystem = {pkgs, ...}: {
    packages.open = pkgs.writeShellApplication {
      name = "open";
      runtimeInputs = [pkgs.w3m pkgs.xdg-utils];
      text = ''
        target="''${1:-}"
        if [ -z "$target" ]; then
          echo "usage: open <url-or-file>" >&2
          exit 2
        fi

        case "$target" in
          *://*) ;;
          *)
            if [ -e "$target" ]; then
              :
            elif [[ "$target" =~ ^[A-Za-z0-9._-]+\.[A-Za-z]{2,}(/.*)?$ ]]; then
              target="https://$target"
            fi
            ;;
        esac

        if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
          exec xdg-open "$target"
        fi

        case "$target" in
          http://*|https://*|ftp://*) exec w3m "$target" ;;
          *)                          exec xdg-open "$target" ;;
        esac
      '';
    };
  };
}
