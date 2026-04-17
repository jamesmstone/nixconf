{
  self,
  inputs,
  ...
}: {
  flake.nixOnDroidConfigurations.pixel9a = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs-droid {system = "aarch64-linux";};
    modules = [
      {
        _module.args.selfpkgs = self.packages.aarch64-linux;
      }
      self.nixOnDroidModules.hostPixel9a
    ];
  };

  flake.nixOnDroidModules.hostPixel9a = {
    pkgs,
    lib,
    selfpkgs,
    ...
  }: {
    imports = [
      self.nixOnDroidModules.android
    ];
    # user.shell = lib.getExe selfpkgs.fish;  # TEMP: Comment out for testing

    # Deploy with fish-variant switcher for instant testing
    environment.packages = with pkgs; [
      # Fish variant switcher script (direct string approach)
      pkgs.writeShellScriptBin "fv" ''
        #!/usr/bin/env bash
        case "$1" in
          simple) exec ${lib.getExe selfpkgs.fish-test-simple} "$@" ;;
          minimal) exec ${lib.getExe selfpkgs.fish-test-minimal} "$@" ;;
          oxide) exec ${lib.getExe selfpkgs.fish-test-zoxide} "$@" ;;
          debug) exec ${lib.getExe selfpkgs.fish-test-debug} "$@" ;;
          *) exec ${lib.getExe selfpkgs.fish} "$@" ;;
        esac
      ''
    ];

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    system.stateVersion = "24.05";
  };
}
