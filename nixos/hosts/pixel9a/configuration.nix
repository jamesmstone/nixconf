{inputs, ...}: {
  flake.nixOnDroidConfigurations.pixel9a = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs {system = "aarch64-linux";};
    modules = [
      ({pkgs, lib, ...}: {
        user.shell = lib.getExe pkgs.fish;

        environment.packages = with pkgs; [
          neovim
          git
          fish
        ];

        nix.extraOptions = ''
          experimental-features = nix-command flakes
        '';

        system.stateVersion = "24.05";
      })
    ];
  };
}
