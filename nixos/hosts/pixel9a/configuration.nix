{self, inputs, ...}: {
  flake.nixOnDroidConfigurations.pixel9a = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs-droid {system = "aarch64-linux";};
    modules = [
      {
        _module.args.selfpkgs = self.packages.aarch64-linux;
      }
      ({
        pkgs,
        lib,
        selfpkgs,
        ...
      }: {
        user.shell = lib.getExe pkgs.fish;

        environment.packages = with pkgs; [
          selfpkgs.environment
        ];

        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';

        system.stateVersion = "24.05";
      })
    ];
  };
}
