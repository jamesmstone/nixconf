{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.tailscale = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.tailscale;
    };
  };
}
