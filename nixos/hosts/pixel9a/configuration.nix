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

    # All fish test variants (custom named wrappers, no conflicts!)
    environment.packages = with pkgs; [
      selfpkgs.fish-test-simple     # Baseline known working
      selfpkgs.fish-test-minimal    # Minimal wrapper test
      selfpkgs.fish-test-zoxide    # Wrapper with single tool
      selfpkgs.fish-test-debug      # Fish with debug flags
      selfpkgs.environment           # The full wrapped environment (CURRENT)
    ];

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    system.stateVersion = "24.05";
  };
}
