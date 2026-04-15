{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.surface_pro_4 = {
    lib,
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
    ];

    users.users.${config.preferences.user.name}.extraGroups = ["video"];

    environment.systemPackages = with pkgs; [
      libcamera
      v4l-utils
    ];

    hardware.firmware = [pkgs.linux-firmware];
  };
}