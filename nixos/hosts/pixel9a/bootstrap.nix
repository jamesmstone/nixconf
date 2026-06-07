# Minimal bootstrap generation for the pixel9a phone.
#
# The full pixel9a config can't be built on-device (the wrapped programs are too
# heavy / some derivations can't run in the on-device sandbox). But it also can't
# be deployed from darter until there's an sshd on the phone to push to — a
# chicken-and-egg. This config breaks it: it's small enough to build on-device
# (only openssh + base, no selfpkgs), and it brings up sshd with darter's key
# authorised. Once it's active, deploy the full config from darter:
#
#   on the phone (fresh bootstrap):
#     nix-on-droid switch --flake github:jamesmstone/nixconf#pixel9aBootstrap
#   then on darter:
#     nix run .#deploy-pixel9a
{
  self,
  inputs,
  ...
}: {
  flake.nixOnDroidConfigurations.pixel9aBootstrap = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs-droid {system = "aarch64-linux";};
    modules = [
      self.nixOnDroidModules.hostPixel9aBootstrap
    ];
  };

  flake.nixOnDroidModules.hostPixel9aBootstrap = {...}: {
    imports = [
      # android pulls in base (user + authorizedKeys) and openssh (sshd on 8022,
      # StrictModes no, darter's key authorised) — everything needed to push from
      # darter, and nothing heavy.
      self.nixOnDroidModules.android
    ];

    # Deliberately do NOT pin user.uid/gid here: the bootstrap is always built
    # on-device, so nix-on-droid's default ($(id -u)/$(id -g) in the build) yields
    # the device's real Android app uid automatically — and survives the uid being
    # reassigned on app reinstall. (The full config in configuration.nix is built
    # off-device, so it has to pin; see the note there.)

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    system.stateVersion = "24.05";
  };
}
