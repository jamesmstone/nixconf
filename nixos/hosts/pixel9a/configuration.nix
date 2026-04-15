{inputs, ...}: {
  flake.nixOnDroidConfigurations.pixel9a = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs {system = "aarch64-linux";};
    modules = [
      ({pkgs, ...}: {
        terminal.shell = "${pkgs.fish}/bin/fish";

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
