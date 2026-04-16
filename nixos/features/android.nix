{
  self,
  pkgs,
  lib,
  ...
}: {
  flake.nixOnDroidModules.android = {...}: {
    imports = [
      self.nixosModules.openssh
    ];

    # Stub options to avoid conflicts with NixOS modules
    # See https://github.com/nix-community/nix-on-droid/issues/469#issuecomment-3178156202
    options.environment.systemPackages = lib.mkOption {
      default = [];
      description = "Nix-on-droid uses `packages`.";
    };
    options.environment.variables = lib.mkOption {
      default = {};
      description = "Nix-on-droid uses `sessionVariables`.";
    };
  };
}
