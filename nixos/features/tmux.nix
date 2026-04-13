{self, ...}: {
  flake.nixosModules.tmux = {
    pkgs,
    config,
    ...
  }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
    ];
  };

  perSystem = {pkgs, ...}: {
    checks.tmux = let
      usr = "tmuxtest";
    in
      pkgs.testers.runNixOSTest {
        name = "tmux";

        nodes.machine = {pkgs, ...}: {
          imports = [
            self.nixosModules.base
            self.nixosModules.extra_hjem
            self.nixosModules.tmux
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
