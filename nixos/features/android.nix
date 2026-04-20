{
  self,
  pkgs,
  lib,
  ...
}: {
  flake.nixOnDroidModules.android = {...}: {
    imports = [
      self.nixOnDroidModules.base
      self.nixOnDroidModules.openssh
    ];


    config.preferences.user.name = "nix-on-droid";
  };
}
