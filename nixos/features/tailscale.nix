{self, ...}: {
  flake.nixosModules.tailscale = {pkgs, ...}: {
    services.tailscale = {
      enable = true;
      package = pkgs.tailscale;
      # authKeyFile = ""; # todo sops
      extraUpFlags = ["--ssh"];
    };
  };
}
