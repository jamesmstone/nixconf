{
  lib,
  inputs,
  self,
  ...
}: {
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    # My whole desktop in one package, includes kityy terminal
    packages.desktop = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      imports = [self.wrappersModules.niri];
      terminal = lib.getExe self'.packages.terminal;
      env = {
        EDITOR = lib.getExe self'.packages.neovim;
      };
    };

    # My primary flake terminal
    packages.terminal =
      (inputs.wrappers.wrapperModules.kitty.apply {
        inherit pkgs;
        imports = [self.wrappersModules.kitty];
        shell = lib.getExe self'.packages.environment;
      }).wrapper;

    # My primary flake shell with all of it's packages
    packages.environment = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = self'.packages.fish;
      runtimeInputs = [
        # nix
        pkgs.nil
        pkgs.nixd
        pkgs.statix
        pkgs.alejandra
        pkgs.manix
        pkgs.nix-inspect
        self'.packages.nh

        # other
        pkgs.file
        pkgs.unzip
        pkgs.zip
        pkgs.p7zip
        pkgs.wget
        pkgs.killall
        pkgs.sshfs
        pkgs.fzf
        pkgs.htop
        pkgs.btop
        pkgs.eza
        pkgs.fd
        pkgs.zoxide
        pkgs.dust
        pkgs.ripgrep
        pkgs.fastfetch
        pkgs.tree-sitter
        pkgs.imagemagick
        pkgs.imv
        pkgs.ffmpeg-full
        pkgs.yt-dlp
        pkgs.lazygit

        # wrapped
        self'.packages.neovimDynamic
        self'.packages.qalc
        self'.packages.lf
        self'.packages.git
        self'.packages.jujutsu
        self'.packages.jjui
        self'.packages.nix-check-bin
      ];
      env = {
        EDITOR = lib.getExe self'.packages.neovimDynamic;
      };
    };

    packages.nix-check-bin = pkgs.writeShellApplication {
      name = "nix-check-bin";
      text = ''
        $EDITOR "$(nix build "$1" --no-link --print-out-paths)/bin"
      '';
    };

    # Fish test packages for debugging Android shell hang
    # All use custom named wrappers to avoid conflicts in single deployment

    # Test 1: Plain fish (baseline known working)
    packages.fish-test-simple = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      exePath = "${pkgs.fish}/bin/fish";
      binName = "fish-test-simple";
    };

    # Test 2: Minimal wrapper
    packages.fish-test-minimal = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      exePath = "${pkgs.fish}/bin/fish";
      binName = "fish-test-minimal";
      runtimeInputs = [];
    };

    # Test 3: Wrapper with zoxide
    packages.fish-test-zoxide = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      exePath = "${pkgs.fish}/bin/fish";
      binName = "fish-test-zoxide";
      runtimeInputs = [pkgs.zoxide];
    };

    # Test 4: Fish with debug (writeScriptBin approach)
    packages.fish-test-debug = pkgs.writeScriptBin "fish-test-debug" ''
      exec ${pkgs.fish}/bin/fish --debug-level 3 "$@"
    '';

    # Test 5: Fish with ZERO runtimeInputs using wrapPackage
    packages.fish-test-zero = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.fish;
      runtimeInputs = [];
    };

    # Test 6: Fish using writeShellApplication (different wrapper approach)
    packages.fish-test-shell = pkgs.writeShellApplication {
      name = "fish-test-shell";
      runtimeInputs = [pkgs.fish];
      text = "exec ${pkgs.fish}/bin/fish";
    };
  };
}
