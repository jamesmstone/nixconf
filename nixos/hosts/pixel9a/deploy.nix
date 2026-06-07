# Build the pixel9a (aarch64) nix-on-droid closure here and push it to the
# phone over SSH, instead of compiling on-device.
#
#   nix run .#deploy-pixel9a
#
# Requires aarch64 emulation on the build host
# (boot.binfmt.emulatedSystems = [ "aarch64-linux" ]). The phone already runs
# sshd on port 8022 with our authorized keys (see nixos/features/openssh.nix,
# pulled in via the android module).
#
# Override defaults with env vars:
#   PIXEL9A=nix-on-droid@100.117.33.114   target host (default: MagicDNS name)
#   PORT=8022                             sshd port
#   FLAKE=.                               flake ref to build from
{
  perSystem = {pkgs, ...}: {
    packages.deploy-pixel9a = pkgs.writeShellApplication {
      name = "deploy-pixel9a";
      runtimeInputs = [pkgs.nix pkgs.openssh];
      text = ''
        flake="''${FLAKE:-.}"
        host="''${PIXEL9A:-nix-on-droid@pixel9a}"
        port="''${PORT:-8022}"
        attr="$flake#nixOnDroidConfigurations.pixel9a.activationPackage"

        echo ">> building $attr (aarch64, via emulation)"
        # --impure: nix-on-droid references store paths via builtins.storePath.
        # --accept-flake-config: trust the nix-on-droid cachix substituter in nixConfig.
        nix build "$attr" --impure --accept-flake-config --out-link /tmp/pixel9a-activate
        out="$(readlink -f /tmp/pixel9a-activate)"

        echo ">> copying closure to $host (port $port)"
        NIX_SSHOPTS="-p $port" nix copy --no-check-sigs --to "ssh://$host" "$out"

        echo ">> activating on $host"
        ssh -p "$port" "$host" "$out/activate"

        echo ">> done"
      '';
    };
  };
}
