{
  self,
  inputs,
  ...
}: {
  flake.nixOnDroidConfigurations.pixel9a = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    pkgs = import inputs.nixpkgs-droid {system = "aarch64-linux";};
    modules = [
      {
        _module.args.selfpkgs = self.packages.aarch64-linux;
      }
      self.nixOnDroidModules.hostPixel9a
    ];
  };

  flake.nixOnDroidModules.hostPixel9a = {
    pkgs,
    lib,
    selfpkgs,
    ...
  }: {
    imports = [
      self.nixOnDroidModules.android
    ];
    # user.shell = lib.getExe selfpkgs.fish;  # TEMP: Comment out for testing

    # Deploy with fish-variant switcher for instant testing
    environment.packages = [
      (pkgs.writeScriptBin "fv" ''
        run_with_debug() {
          echo "[DEBUG] Starting: $*"
          ${pkgs.coreutils}/bin/timeout 5 "$@"
          status=$?
          if [ $status -ne 0 ]; then
            echo "[ERROR] Command failed with status $status"
          fi
          echo "[DEBUG] Finished: $*"
          echo
          return $status
        }

        run_all() {
          run_with_debug ${pkgs.fish}/bin/fish "$@" # DEBUG LOGS:  works
          run_with_debug ${selfpkgs.fish-test-simple}/bin/fish-test-simple "$@" # DEBUG LOGS:  hangs / freezes
          run_with_debug ${selfpkgs.fish-test-minimal}/bin/fish-test-minimal "$@" # DEBUG LOGS:  hangs / freezes
          run_with_debug ${selfpkgs.fish-test-zoxide}/bin/fish-test-zoxide "$@" # DEBUG LOGS:  hangs / freezes
          run_with_debug ${selfpkgs.fish-test-debug}/bin/fish-test-debug "$@" # DEBUG LOGS:  hangs / freezes
          run_with_debug ${selfpkgs.fish-test-zero}/bin/fish "$@" # DEBUG LOGS:  NEW - zero runtimeInputs wrapper
          run_with_debug ${selfpkgs.fish-test-shell}/bin/fish-test-shell "$@" # DEBUG LOGS:  NEW - shell application
        }

        case "$1" in
          all)
            shift
            run_all "$@"
            ;;
          s)
            shift
            exec ${pkgs.fish}/bin/fish "$@"
            ;;
          simple)
            shift
            exec ${selfpkgs.fish-test-simple}/bin/fish-test-simple "$@"
            ;;
          minimal)
            shift
            exec ${selfpkgs.fish-test-minimal}/bin/fish-test-minimal "$@"
            ;;
          oxide)
            shift
            exec ${selfpkgs.fish-test-zoxide}/bin/fish-test-zoxide "$@"
            ;;
          debug)
            shift
            exec ${selfpkgs.fish-test-debug}/bin/fish-test-debug "$@"
            ;;
          zero)
            shift
            exec ${selfpkgs.fish-test-zero}/bin/fish "$@"
            ;;
          shell)
            shift
            exec ${selfpkgs.fish-test-shell}/bin/fish-test-shell "$@"
            ;;
          *)
            exec ${selfpkgs.environment}/bin/fish "$@"
            ;;
        esac
      '')
    ];

    nix.extraOptions = ''
      experimental-features = nix-command flakes
    '';

    system.stateVersion = "24.05";
  };
}
