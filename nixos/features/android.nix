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

    config = {
      preferences.user.name = "nix-on-droid";

      environment.etc."resolv.conf".text = lib.mkForce ''
        # Use Tailscale's local resolver
        nameserver 100.100.100.100
        # Add tailnet search domain so short names work
        search finch-moth.ts.net
        # Fallback to a public DNS
        nameserver 1.1.1.1
        nameserver 8.8.8.8
      '';
    };
  };
}
