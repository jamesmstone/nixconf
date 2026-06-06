# tmux configured as a wrapped package, driven by NixOS options (modelled on
# nixpkgs programs/tmux.nix). All location config resolves at build time from
# `self.locations` + `preferences.user.city` + the host name.
{
  self,
  inputs,
  ...
}: let
  # Build the status-bar helper scripts for a city. Shared by the module and its
  # test so the test can reference the exact same scripts via Nix, instead of
  # scraping store paths out of the generated config at runtime. The scripts
  # depend only on the city (which clocks), not on showLoad.
  mkStatusScripts = {
    pkgs,
    city,
  }: let
    inherit (pkgs) lib;
    locations = self.locations;
    remoteClocks =
      lib.filter (c: c.clock && c.name != city)
      (lib.mapAttrsToList (name: v: v // {inherit name;}) locations);
    # Below this client width, status-right drops the clocks (load only) and
    # status-left drops the cwd, to keep a narrow client uncluttered.
    clockMinWidth = 100;
  in {
    left = pkgs.writeShellApplication {
      name = "tmux-status-left";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        width="''${1:-9999}"
        path="''${2:-}"
        if [ "$width" -ge ${toString clockMinWidth} ] && [ -n "$path" ]; then
          printf '%s ' "''${path/#"$HOME"/\~}"
        fi
      '';
    };
    right = pkgs.writeShellApplication {
      name = "tmux-status-right";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        width="''${1:-9999}"
        load="$(awk '{print $1}' /proc/loadavg)"
        if [ "$width" -ge ${toString clockMinWidth} ]; then
          printf '${lib.concatMapStringsSep "  " (c: "${c.label}: %s") remoteClocks}  %s  %s' \
            ${lib.concatMapStringsSep " " (c: "\"$(TZ=${c.tz} date +%H:%M)\"") remoteClocks} \
            "$(date +%H:%M:%S)" \
            "$load"
        else
          printf '%s' "$load"
        fi
      '';
    };
  };
in {
  flake.nixosModules.tmux = {
    pkgs,
    config,
    lib,
    ...
  }: let
    cfg = config.preferences.tmux;
    city = config.preferences.user.city;
    locations = self.locations;
    selfpkgs = self.packages.${pkgs.stdenv.hostPlatform.system};

    hostColors = {
      darter = "colour22";
      hermanii = "colour24";
      herman = "colour88";
      sgp = "colour94";
    };

    status = mkStatusScripts {inherit pkgs city;};
    statusLeftScript = status.left;
    statusRightScript = status.right;

    weathrPkg = inputs.weathr.packages.${pkgs.stdenv.hostPlatform.system}.default;

    # Screensaver weather, configured for the current city. weathr reads
    # $XDG_CONFIG_HOME/weathr/config.toml and has no CLI override, so point it at
    # a sealed store dir.
    weathrConfig = {
      silent = true;
      hide_hud = false;
      location = {
        latitude = builtins.fromJSON locations.${city}.latitude;
        longitude = builtins.fromJSON locations.${city}.longitude;
        auto = false;
        hide = false;
        display = "city";
        inherit city;
      };
      units = {
        temperature = "celsius";
        wind_speed = "kmh";
        precipitation = "mm";
      };
    };
    weathrConfigDir = pkgs.runCommand "weathr-config" {} ''
      install -Dm444 \
        ${(pkgs.formats.toml {}).generate "weathr-config.toml" weathrConfig} \
        $out/weathr/config.toml
    '';
    weathrConfigured = self.lib.writeShellApplicationWithDefaults pkgs {
      name = "weathr";
      runtimeInputs = [weathrPkg];
      text = ''
        export XDG_CONFIG_HOME=${weathrConfigDir}
        exec weathr "$@"
      '';
    };

    urlPicker = pkgs.writeShellApplication {
      name = "tmux-url-picker";
      runtimeInputs = [pkgs.tmux pkgs.gnugrep pkgs.coreutils pkgs.fzf selfpkgs.open];
      text = ''
        url="$(tmux capture-pane -J -p -S - -E - \
          | grep -oP '(https?://[^\s<>"'"'"']+)' \
          | sort -u \
          | fzf --reverse --no-multi --no-info --prompt='URL> ')"
        if [ -n "$url" ]; then
          open "$url"
        fi
      '';
    };

    lockScreensaver = pkgs.writeShellApplication {
      name = "tmux-lock-screensaver";
      runtimeInputs = [weathrConfigured pkgs.cmatrix];
      text = ''
        case "$((RANDOM % 2))" in
          0) exec weathr "$@" ;;
          *) exec cmatrix "$@" ;;
        esac
      '';
    };

    # Defined here (not inline) because when persistence is on we route it through
    # tmux-continuum: continuum attaches its periodic auto-save hook to
    # status-right as it loads, so status-right must be set just before
    # continuum's run-shell or auto-save silently breaks.
    loadStatusRight =
      lib.optionalString cfg.showLoad
      "set -g status-right '#[default] #(${lib.getExe statusRightScript} #{client_width})'";

    tmuxConf = pkgs.writeText "tmux.conf" ''
      set -g default-terminal "screen-256color"
      setw -g clock-mode-style 24
      set -g history-limit 10000
      set -g mouse on

      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on
      setw -g mode-keys vi
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi y send-keys -X copy-selection
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D
      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      bind r run-shell '${pkgs.tmux}/bin/tmux source-file "$TMUX_CONF"' \; display "Config reloaded"

      set -g status-bg ${cfg.statusColor}
      set -g status-fg white
      set -g status-interval 5
      set -g status-right-length 60
      set -g status-left-length 60
      set -g status-left '#[default]#(${lib.getExe statusLeftScript} #{client_width} "#{pane_current_path}")[#S] '
      ${lib.optionalString (!cfg.persist) loadStatusRight}

      ${lib.optionalString cfg.persist ''
        # resurrect must load before continuum (continuum drives resurrect's
        # save/restore), so status-right must be set just before continuum's
        # run-shell or auto-save silently breaks.
        set -g @resurrect-capture-pane-contents 'on'
        set -g @resurrect-strategy-nvim 'session'
        run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux

        # Set status-right here, right before continuum's run-shell, so continuum
        # can attach its auto-save hook to it.
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
        ${loadStatusRight}
        run-shell ${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux
      ''}

      set -g lock-after-time 300
      set -g lock-command '${lib.getExe lockScreensaver}'

      bind-key b if-shell '[ "#{pane_width}" -gt "$((#{pane_height} * 2))" ]' \
        'split-window -h -c "#{pane_current_path}"' \
        'split-window -v -c "#{pane_current_path}"'

      # Toggle htop in a popup. The popup runs a nested session so the same key
      # closes it: inside the popup, prefix+h detaches; outside, it opens.
      bind-key h if-shell -F '#{==:#{session_name},htop-popup}' \
        'detach-client' \
        'display-popup -E -w 90% -h 90% "${lib.getExe pkgs.tmux} new-session -A -s htop-popup ${lib.getExe pkgs.htop}"'

      bind-key C-c if-shell -F '#{==:#{session_name},matui-popup}' \
        'detach-client' \
        'display-popup -E -w 90% -h 90% "${lib.getExe pkgs.tmux} new-session -A -s matui-popup ${lib.getExe selfpkgs.matui-configured}"'

      bind-key C-a if-shell -F '#{==:#{session_name},spotify-popup}' \
        'detach-client' \
        'display-popup -E -w 90% -h 90% "${lib.getExe pkgs.tmux} new-session -A -s spotify-popup ${lib.getExe pkgs.spotify-player}"'

      bind-key u display-popup -E -w 80% -h 70% "${lib.getExe urlPicker}"

      # Toggle dictation. M-d so the default detach-client binding survives.
      bind-key M-d run-shell "${lib.getExe selfpkgs.james-dictation}"

      bind-key a run-shell -b "${lib.getExe selfpkgs.tmux-ai-window-renamer}"

      # Toggle keybindings/prefix on/off with F12 for nested tmux sessions.
      bind -T root F12 \
        set prefix None \;\
        set key-table off \;\
        set status-style "fg=colour245,bg=colour238" \;\
        if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
        refresh-client -S

      bind -T off F12 \
        set -u prefix \;\
        set -u key-table \;\
        set -u status-style \;\
        refresh-client -S
    '';

    wrappedTmux = pkgs.writeShellApplication {
      name = "tmux";
      runtimeInputs = [pkgs.tmux];
      text = ''
        export TMUX_CONF=${tmuxConf}
        exec ${pkgs.tmux}/bin/tmux -f "$TMUX_CONF" "$@"
      '';
    };
  in {
    options.preferences.user.city = lib.mkOption {
      type = lib.types.str;
      default = "Copenhagen";
      description = "Current city; indexes self.locations for tmux clocks/weather.";
    };

    options.preferences.tmux = {
      showLoad = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show load average in the tmux status bar.";
      };
      persist = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Persist and restore sessions with resurrect + continuum.";
      };
      statusColor = lib.mkOption {
        type = lib.types.str;
        default = hostColors.${config.networking.hostName} or "colour236";
        description = "tmux status bar background colour (tmux colourNNN).";
      };
    };

    config = {
      environment.systemPackages = [wrappedTmux];
    };
  };

  perSystem = {
    pkgs,
    lib,
    ...
  }: {
    checks.tmux = let
      usr = "tmuxtest";

      # The exact status scripts each node uses, built here in Nix so the test can
      # reference them directly (no runtime store-path scraping). Same derivation
      # inputs as the nodes' scripts, so these are the identical store paths.
      statusMel = mkStatusScripts {
        inherit pkgs;
        city = "Melbourne";
      };
      statusCph = mkStatusScripts {
        inherit pkgs;
        city = "Copenhagen";
      };
      statusHk = mkStatusScripts {
        inherit pkgs;
        city = "Hong Kong";
      };

      # Attach a real client inside a pty of a given width, then ask tmux to
      # expand status-right (which runs the #() status script) for that client —
      # a true end-to-end render of the status bar at a fixed width.
      renderStatus = pkgs.writeShellScriptBin "render-status" ''
        set -u
        cols="$1"
        logf="$(mktemp)"
        tmux kill-session -t render 2>/dev/null || true
        tmux new-session -d -s render -x "$cols" -y 50
        # Attach a real client in a pty of the requested width and log everything
        # tmux draws (status bar included) to $logf. `sleep` keeps the pty's stdin
        # open so `script` doesn't see EOF (no controlling tty under the test
        # driver) and tear the client down before the bar paints.
        ( sleep 30 | ${pkgs.util-linux}/bin/script -qfc \
            "stty cols $cols rows 50; TERM=screen-256color exec tmux attach -t render" \
            "$logf" >/dev/null 2>&1 ) &
        bgpid=$!
        client=""
        for _ in $(seq 1 100); do
          client="$(tmux list-clients -t render -F '#{client_width} #{client_name}' 2>/dev/null \
            | while read -r w n; do [ "$w" = "$cols" ] && { printf '%s' "$n"; break; }; done)"
          [ -n "$client" ] && break
          sleep 0.2
        done
        if [ -z "$client" ]; then
          echo "render-status: no client attached at width $cols" >&2
          tmux list-clients -t render -F 'have client=#{client_name} w=#{client_width}' >&2 2>/dev/null || true
          kill "$bgpid" 2>/dev/null || true
          exit 1
        fi
        # Force a redraw and let the status line (incl. the #() script) paint.
        tmux refresh-client -t "$client" 2>/dev/null || true
        sleep 3
        tmux kill-session -t render 2>/dev/null || true
        sleep 1
        # Emit the raw terminal capture; the caller greps it for clock labels.
        cat "$logf"
        kill "$bgpid" 2>/dev/null || true
        rm -f "$logf"
      '';

      mkNode = {
        city,
        persist,
        showLoad,
        statusColor ? null,
        extraPkgs ? [],
      }: {...}: {
        imports = [
          self.nixosModules.base
          self.nixosModules.extra_hjem
          self.nixosModules.tmux
        ];

        preferences.user.name = usr;
        preferences.user.city = city;
        preferences.tmux.persist = persist;
        preferences.tmux.showLoad = showLoad;
        preferences.tmux.statusColor = lib.mkIf (statusColor != null) statusColor;
        users.users.${usr}.isNormalUser = true;
        environment.systemPackages = extraPkgs;
      };
    in
      pkgs.testers.runNixOSTest {
        name = "tmux";

        nodes.machine = mkNode {
          city = "Melbourne";
          persist = true;
          showLoad = true;
          extraPkgs = [renderStatus pkgs.util-linux statusMel.left statusMel.right];
        };
        nodes.cph = mkNode {
          city = "Copenhagen";
          persist = true;
          showLoad = true;
          statusColor = "colour94";
          extraPkgs = [statusCph.right];
        };
        nodes.hk = mkNode {
          city = "Hong Kong";
          persist = true;
          showLoad = true;
          extraPkgs = [statusHk.right];
        };
        nodes.minimal = mkNode {
          city = "Melbourne";
          persist = false;
          showLoad = false;
        };

        testScript = ''
          import re

          # The status scripts, referenced directly from Nix (identical store
          # paths to the ones each node's wrapped tmux runs).
          sr_mel = "${lib.getExe statusMel.right}"
          sl_mel = "${lib.getExe statusMel.left}"
          sr_cph = "${lib.getExe statusCph.right}"
          sr_hk = "${lib.getExe statusHk.right}"

          start_all()
          for m in (machine, cph, hk, minimal):
              m.wait_for_unit("multi-user.target")
              # Start a server so show-options/list-keys reflect the loaded conf.
              m.succeed("tmux new-session -d -s t")

          def gopt(m, name):
              return m.succeed(f"tmux show-options -g {name}").strip()

          def gwopt(m, name):
              return m.succeed(f"tmux show-options -gw {name}").strip()

          # ============ machine: Melbourne, persist + showLoad on ============
          machine.succeed("command -v tmux")
          machine.succeed("tmux has-session -t t")

          # --- status-right width gating ---
          big = machine.succeed(f"{sr_mel} 120")
          assert "CM:" in big and "CPH:" in big, f"large status-right missing clocks: {big!r}"
          assert "MEL:" not in big, f"current city (Melbourne) must be filtered out: {big!r}"
          assert re.search(r"\d\d:\d\d:\d\d", big), f"large status-right missing local clock: {big!r}"

          small = machine.succeed(f"{sr_mel} 50")
          assert "CM:" not in small and "CPH:" not in small, f"small status-right must drop clocks: {small!r}"
          assert not re.search(r"\d\d:\d\d:\d\d", small), f"small status-right must drop local clock: {small!r}"

          # boundary at clockMinWidth = 100
          assert "CM:" not in machine.succeed(f"{sr_mel} 99"), "width 99 must be treated as small"
          assert "CM:" in machine.succeed(f"{sr_mel} 100"), "width 100 must be treated as large"

          # --- status-left width gating + $HOME -> ~ ---
          left_big = machine.succeed(f"HOME=/home/${usr} {sl_mel} 120 /home/${usr}/proj")
          assert "~/proj" in left_big, f"large status-left must show cwd (~ collapsed): {left_big!r}"
          left_small = machine.succeed(f"HOME=/home/${usr} {sl_mel} 50 /home/${usr}/proj")
          assert left_small.strip() == "", f"small status-left must drop cwd: {left_small!r}"

          # --- options ---
          assert gopt(machine, "mouse") == "mouse on"
          assert gopt(machine, "history-limit") == "history-limit 10000"
          assert gopt(machine, "status-interval") == "status-interval 5"
          assert gopt(machine, "lock-after-time") == "lock-after-time 300"
          assert "screen-256color" in gopt(machine, "default-terminal")
          assert gopt(machine, "base-index") == "base-index 1"
          assert gopt(machine, "renumber-windows") == "renumber-windows on"
          assert gwopt(machine, "pane-base-index") == "pane-base-index 1"
          assert gwopt(machine, "mode-keys") == "mode-keys vi"
          assert gwopt(machine, "clock-mode-style") == "clock-mode-style 24"
          # per-host status colour: hostname "machine" is unknown -> default
          assert gopt(machine, "status-bg") == "status-bg colour236", gopt(machine, "status-bg")

          # --- keybindings ---
          prefix = machine.succeed("tmux list-keys -T prefix")
          for marker in ("htop-popup", "matui-popup", "spotify-popup",
                         "tmux-url-picker", "tmux-ai-window-renamer", "james-dictation"):
              assert marker in prefix, f"missing prefix binding referencing {marker}"
          assert "source-file" in prefix, "missing prefix-r reload binding"
          assert prefix.count("split-window") >= 3, "expected smart-split (b) + v + s splits"

          vicopy = machine.succeed("tmux list-keys -T copy-mode-vi")
          assert "begin-selection" in vicopy and "copy-selection" in vicopy

          root = machine.succeed("tmux list-keys -T root")
          for k in ("M-Left", "M-Right", "M-Up", "M-Down"):
              assert k in root, f"missing pane-nav binding {k}"
          assert "F12" in root, "missing root F12 toggle"
          assert "F12" in machine.succeed("tmux list-keys -T off"), "missing off-table F12 toggle"

          # --- persistence on ---
          assert gopt(machine, "@continuum-restore") == "@continuum-restore on"
          assert gopt(machine, "@continuum-save-interval") == "@continuum-save-interval 15"
          assert gopt(machine, "@resurrect-capture-pane-contents") == "@resurrect-capture-pane-contents on"

          # --- stretch: true rendered status bar at a fixed width ---
          wide = machine.succeed("render-status 200")
          assert "CM:" in wide and "CPH:" in wide, f"rendered wide bar missing clocks: {wide!r}"
          assert "MEL:" not in wide, f"rendered wide bar must filter current city: {wide!r}"
          narrow = machine.succeed("render-status 50")
          assert "CM:" not in narrow, f"rendered narrow bar must drop clocks: {narrow!r}"

          # ============ cph: Copenhagen, custom status colour ============
          big_cph = cph.succeed(f"{sr_cph} 120")
          assert "CM:" in big_cph and "MEL:" in big_cph, f"cph clocks: {big_cph!r}"
          assert "CPH:" not in big_cph, f"Copenhagen must be filtered on the cph node: {big_cph!r}"
          assert gopt(cph, "status-bg") == "status-bg colour94", gopt(cph, "status-bg")

          # ============ hk: Hong Kong (a non-clock city) shows all 3 clocks ============
          big_hk = hk.succeed(f"{sr_hk} 120")
          for label in ("CM:", "CPH:", "MEL:"):
              assert label in big_hk, f"Hong Kong node should show all default clocks, missing {label}: {big_hk!r}"

          # ============ minimal: persist=false, showLoad=false ============
          # continuum/resurrect options are absent
          assert minimal.succeed("tmux show-options -gq @continuum-restore").strip() == "", \
              "persist=false must not set @continuum-restore"
          assert minimal.succeed("tmux show-options -gq @resurrect-capture-pane-contents").strip() == "", \
              "persist=false must not set resurrect options"
          # showLoad=false => our status-right script is never wired in (tmux keeps its default)
          assert "tmux-status-right" not in minimal.succeed("tmux show-options -g status-right"), \
              "showLoad=false must leave our status-right script out"
        '';
      };
  };
}
