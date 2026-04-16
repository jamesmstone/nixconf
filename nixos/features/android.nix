{self, ...}: {
  flake.nixOnDroidModules.android = {
    pkgs,
    config,
    lib,
    ...
  }: let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    user = config.preferences.user.name;
    timezone = config.preferences.user.timezone;
    environment = config.environment;
  in {
    imports = [
    ];

    # See https://github.com/nix-community/nix-on-droid/issues/469#issuecomment-3178156202
    options = {
      environment.systemPackages = lib.mkOption {
        default = [];
        description = "Nix-on-droid uses `packages`.";
      };
      environment.variables = lib.mkOption {
        default = {};
        description = "Nix-on-droid uses `sessionVariables`.";
      };
    };

    config = {
      environment.packages = environment.systemPackages;
      environment.sessionVariables = environment.variables;
    };

    _module.args.selfpkgs = self.packages.aarch64-linux;
  };
}
