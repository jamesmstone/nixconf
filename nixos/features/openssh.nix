{self, ...}: {
  flake.nixosModules.openssh = {
    config,
    pkgs,
    ...
  }: {
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "prohibit-password";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    users.users.${config.preferences.user.name}.openssh.authorizedKeys.keys = config.preferences.user.authorizedKeys;
    users.users.root.openssh.authorizedKeys.keys = config.preferences.user.authorizedKeys;

    environment.systemPackages = [pkgs.mosh];
  };

  flake.nixOnDroidModules.openssh = {
    config,
    pkgs,
    ...
  }: {
    services.openssh = {
      enable = true;
      #hostKeys = [];
    };

    environment.systemPackages = [pkgs.mosh];

    # Create the key file used by sshd.
    environment.etc."ssh/authorized_keys.d/${config.preferences.user.name}".text =
      builtins.concatStringsSep "\n" config.preferences.user.authorizedKeys + "\n";
  };

  # tests
  perSystem = {pkgs, ...}: {
    checks.openssh = let
      sshKey = pkgs.runCommand "ssh-test-key" {} ''
        mkdir -p $out

        ${pkgs.lib.getExe' pkgs.openssh "ssh-keygen"} \
          -t ed25519 \
          -N "" \
          -f $out/id_ed25519 \
          -q
      '';

      pub = "${sshKey}/id_ed25519.pub";
      priv = "${sshKey}/id_ed25519";
    in
      pkgs.testers.runNixOSTest {
        name = "openssh";

        nodes = {
          server = {pkgs, ...}: let
            usr = "test";
          in {
            imports = [
              self.nixosModules.base
              self.nixosModules.openssh
            ];

            preferences.user.name = usr;
            users.users.${usr}.isNormalUser = true;
            preferences.user.authorizedKeys = [
              (builtins.readFile pub)
            ];

            services.openssh.enable = true;
          };

          client = {pkgs, ...}: {
            environment.systemPackages = [pkgs.openssh];
          };
        };

        testScript = ''
          start_all()

          # ensure client can use private key
          client.succeed("""
            mkdir -p /root/.ssh
            cp ${priv} /root/id_ed25519
            chmod 600 /root/id_ed25519
          """)
          # ensure server is ready
          server.wait_for_unit("sshd.service")

          # SSH test
          client.succeed(
            "ssh -o StrictHostKeyChecking=no "
            "-i /root/id_ed25519 test@server 'echo success'"
          )
        '';
      };
  };
}
