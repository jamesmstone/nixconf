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

  flake.nixosModules.hostHerman = {
    lib,
    pkgs,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel

      self.nixosModules.base
      self.nixosModules.general
      self.nixosModules.desktop
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "herman";

    networking.networkmanager.enable = true;

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    system.stateVersion = "25.11";
  };
}
