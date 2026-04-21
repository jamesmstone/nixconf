{self, ...}: {
  flake.nixosModules.desktop = {
    pkgs,
    config,
    ...
  }: let
    selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    user = config.preferences.user.name;
    inherit (config.preferences.user) timezone;
  in {
    imports = [
      self.nixosModules.gtk

      self.nixosModules.pipewire
      self.nixosModules.firefox
      self.nixosModules.chromium
    ];

    programs.niri.enable = true;
    programs.niri.package = selfpkgs.niri;

    # Auto-login and start niri from the login shell on tty1.
    # Works with bash (test VMs) and fish (production) login shells.
    services.getty.autologinUser = user;
    programs.bash.loginShellInit = ''
      if [ "$(tty)" = "/dev/tty1" ]; then
        exec ${pkgs.lib.getExe selfpkgs.niri} >/tmp/niri.log 2>&1
      fi
    '';
    programs.fish.enable = true;
    programs.fish.loginShellInit = ''
      if status is-login; and test (tty) = /dev/tty1
        exec ${pkgs.lib.getExe selfpkgs.niri} >/tmp/niri.log 2>&1
      end
    '';

    # preferences.autostart = [selfpkgs.quickshellWrapped];
    preferences.autostart = [selfpkgs.noctalia-shell];

    environment.systemPackages = [
      selfpkgs.terminal
      pkgs.pcmanfm
      selfpkgs.noctalia-shell
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      ubuntu-sans
      cm_unicode
      unifont
    ];

    fonts.fontconfig.defaultFonts = {
      serif = ["Ubuntu Sans"];
      sansSerif = ["Ubuntu Sans"];
      monospace = ["JetBrainsMono Nerd Font"];
    };

    time.timeZone = timezone;
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "uk_UA.UTF-8";
      LC_IDENTIFICATION = "uk_UA.UTF-8";
      LC_MEASUREMENT = "uk_UA.UTF-8";
      LC_MONETARY = "uk_UA.UTF-8";
      LC_NAME = "uk_UA.UTF-8";
      LC_NUMERIC = "uk_UA.UTF-8";
      LC_PAPER = "uk_UA.UTF-8";
      LC_TELEPHONE = "uk_UA.UTF-8";
      LC_TIME = "uk_UA.UTF-8";
    };

    services.upower.enable = true;

    security.polkit.enable = true;

    hardware = {
      enableAllFirmware = true;

      bluetooth.enable = true;
      bluetooth.powerOnBoot = true;

      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };

  # tests

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks.desktop = let
      usr = "niritest";
      # Re-import nixpkgs with allowUnfree so the test nodes' read-only
      # nixpkgs.config inherits it (enabling firmware, fonts, etc.)
      testPkgs = import pkgs.path {
        inherit system;
        config.allowUnfree = true;
      };
    in
      testPkgs.testers.runNixOSTest {
        name = "desktop";
        # enableDebugHook = true;
        # nix run .#checks.x86_64-linux.desktop.driverInteractive
        # https://nixos.org/manual/nixos/stable/#sec-nixos-test-interactive-configuration

        nodes.machine = {...}: {
          imports = [
            self.nixosModules.base
            self.nixosModules.general
            self.nixosModules.desktop
          ];

          preferences.user.name = usr;

          environment.systemPackages = [pkgs.grim pkgs.imagemagick];

          # virtio-gpu provides card0 + renderD128, which smithay needs for GBM.
          # Software rendering vars are needed because the test VM has no virgl.
          boot.kernelModules = ["virtio_gpu"];
          virtualisation.qemu.options = ["-vga none -device virtio-gpu-pci"];
          virtualisation.resolution = {
            x = 1920;
            y = 1080;
          };
          environment.variables = {
            LIBGL_ALWAYS_SOFTWARE = "1";
            MESA_LOADER_DRIVER_OVERRIDE = "kms_swrast";
          };
        };

        testScript = ''
          start_all()
          machine.wait_for_unit("multi-user.target", timeout=60)
          # Wayland socket confirms niri is running and accepting clients
          machine.wait_for_file("/run/user/1000/wayland-1", timeout=60)
          # Confirm the niri process itself is up (not just a leftover socket)
          machine.wait_until_succeeds("pgrep -u ${usr} niri", timeout=15)

          # Take a screenshot via grim running inside the niri session
          machine.wait_until_succeeds(
            "su - ${usr} -c "
            "'WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 "
            "grim /tmp/niri-desktop.png'",
            timeout=30,
          )
          machine.succeed("test -s /tmp/niri-desktop.png")
          machine.copy_from_vm("/tmp/niri-desktop.png", "")

          # Assert we are looking at a graphical desktop, not a text console.
          # A console is near-black (mean ≈ 0.01–0.03); any graphical output
          # from niri (wallpaper, default background) scores well above 0.05.
          machine.succeed(
            "convert /tmp/niri-desktop.png -colorspace gray "
            "-format '%[fx:mean]' info: "
            "| awk '{exit ($1 < 0.05)}'"
          )
        '';
      };
  };
}
