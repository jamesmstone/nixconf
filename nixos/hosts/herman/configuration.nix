{
  inputs,
  self,
  lib,
  ...
}: {
  flake.nixosConfigurations.herman = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      self.nixosModules.hostHerman
    ];
  };

  flake.nixosModules.hostHerman = {pkgs, ...}: {
    imports = [
      self.nixosModules.base
      self.nixosModules.general
      self.nixosModules.desktop
      self.nixosModules.tailscale
      self.nixosModules.openssh
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "herman";

    networking.networkmanager.enable = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    system.stateVersion = "25.11";
  };
}
