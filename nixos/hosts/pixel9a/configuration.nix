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
      # Fish variant switcher
      (pkgs.writeScriptBin "fv" (lib.concatStrings [
        "case \"$1\" in\n"
        "  simple)   exec ${selfpkgs.fish-test-simple}/bin/fish-test-simple \"$@\" ;;\n"
        "  minimal)  exec ${selfpkgs.fish-test-minimal}/bin/fish-test-minimal \"$@\" ;;\n"
        "  oxide)    exec ${selfpkgs.fish-test-zoxide}/bin/fish-test-zoxide \"$@\" ;;\n"
        "  debug)    exec ${selfpkgs.fish-test-debug}/bin/fish-test-debug \"$@\" ;;\n"
        "  *)        exec ${selfpkgs.environment}/bin/fish \"$@\" ;;\n"
        "esac\n"
      ]))
    ];

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    system.stateVersion = "24.05";
  };
}
