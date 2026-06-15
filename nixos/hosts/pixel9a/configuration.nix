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

    # user.uid/gid default to $(id -u)/$(id -g) run *in the build sandbox*, which
    # is correct on-device but wrong off-device (the sandbox's 1000/100). A
    # mismatched uid in /etc/passwd means the running uid has no passwd entry —
    # getpwuid fails and sshd/login/builds break. Since this is built off-device
    # (on darter), take the device's real ids from the environment: deploy.nix
    # queries the phone over SSH and exports PIXEL9A_UID/GID before building, so it
    # stays correct even though Android reassigns the app uid on reinstall. The
    # fallback is this device's current value, for a plain `nix build`.
    user.uid = let v = builtins.getEnv "PIXEL9A_UID"; in if v != "" then lib.toInt v else 10410;
    user.gid = let v = builtins.getEnv "PIXEL9A_GID"; in if v != "" then lib.toInt v else 10410;

    # user.shell = lib.getExe selfpkgs.fish;  # TEMP: Comment out for testing

    # Deploy with fish-variant switcher for instant testing
    environment.packages = [
      pkgs.busybox
      pkgs.curl
      pkgs.openssh
      pkgs.dig
      selfpkgs.git
      selfpkgs.claude-code
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
          run_with_debug ${selfpkgs.fish-test-zero}/bin/fish "$@" # DEBUG LOGS:  hangs / freezes
          run_with_debug ${selfpkgs.fish-test-shell}/bin/fish-test-shell "$@" # DEBUG LOGS:  hangs / freezes
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
