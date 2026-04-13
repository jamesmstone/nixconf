{self, ...}: {
  flake.nixosModules.tmux = {
    pkgs,
    config,
    ...
  }: let
    user = config.preferences.user.name;
  in {
    environment.systemPackages = [pkgs.tmux];

    hjem.users.${user} = {
      files = {
        ".tmux.conf".text = ''
          set -g default-terminal "screen-256color"
          set -g base-index 1
          setw -g pane-base-index 1
          set -g renumber-windows on
          set -g status-position bottom
          set -g status-left ""
          set -g status-right "#{?pane_synchronized,#[fg=red]SYNC #[default],}#H %H:%M %d-%b-%y"
          set -g status-style bg=black,fg=white
          setw -g window-status-current-style fg=white,bg=blue
          set -g pane-border-style fg=black
          set -g pane-active-border-style fg=blue
          setw -g mouse on
          set -g history-limit 10000
          bind r source-file ~/.tmux.conf \; display "Config reloaded"
          bind v split-window -h -c "#{pane_current_path}"
          bind s split-window -v -c "#{pane_current_path}"
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R
          bind -n M-Left select-pane -L
          bind -n M-Right select-pane -R
          bind -n M-Up select-pane -U
          bind -n M-Down select-pane -D
          set-window-option -g mode-keys vi
          bind -T copy-mode-vi v send-keys -X begin-selection
          bind -T copy-mode-vi y send-keys -X copy-selection
        '';
      };
    };
  };

  perSystem = {pkgs, ...}: {
    checks.tmux = let
      usr = "tmuxtest";
    in
      pkgs.testers.runNixOSTest {
        name = "tmux";

        nodes.machine = {
          pkgs,
          ...
        }: {
          imports = [
            self.nixosModules.base
            self.nixosModules.extra_hjem
          ];

          preferences.user.name = usr;
          users.users.${usr} = {
            isNormalUser = true;
          };
        };

        testScript = ''
          start_all()

          machine.wait_for_unit("multi-user.target")

          # tmux binary is present
          machine.succeed("command -v tmux")

          # tmux config file exists for user
          machine.succeed("test -f /home/${usr}/.tmux.conf")

          # tmux config contains expected settings
          machine.succeed("grep -q 'default-terminal' /home/${usr}/.tmux.conf")

          # Start a tmux session
          machine.succeed("su - ${usr} -c 'tmux new-session -d -s test'")

          # Verify tmux session is running
          machine.succeed("su - ${usr} -c 'tmux has-session -t test'")

          # Kill tmux session
          machine.succeed("su - ${usr} -c 'tmux kill-session -t test'")
        '';
      };
  };
}
