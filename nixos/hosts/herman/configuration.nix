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
    config,
    ...
  }: {
    imports = [
      self.nixosModules.base
      self.nixosModules.general
      self.nixosModules.desktop
      inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    ];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "herman";

    networking.networkmanager.enable = true;

    users.users.${config.preferences.user.name}.extraGroups = ["video"];

    environment.systemPackages = with pkgs; [
      libcamera
      v4l-utils
    ];

    hardware.firmware = [pkgs.linux-firmware];

    system.stateVersion = "25.11";
  };
}
