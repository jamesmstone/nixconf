{self, ...}: {
  flake.nixosModules.firefox = {
    pkgs,
    config,
    lib,
    ...
  }: let
    user = config.preferences.user.name;

    # Convert _bookmarks.nix toolbar items to Firefox ManagedBookmarks policy entries.
    # Nested folders are preserved. javascript: URLs are dropped.
    # No toplevel_name entry → items appear directly on the bookmarks toolbar.
    # ManagedBookmarks is applied on every Firefox startup (unlike Bookmarks which
    # only applies on first profile creation), so existing profiles stay in sync.
    toolbarItems = (builtins.head (import ./_bookmarks.nix)).bookmarks;
    toManagedBookmarks = items:
      lib.concatMap (
        item:
          if item ? bookmarks
          then
            let children = toManagedBookmarks item.bookmarks;
            in if children != [] then [{name = item.name; children = children;}] else []
          else if (item ? url) && lib.strings.hasPrefix "http" item.url
          then [{name = item.name; url = item.url;}]
          else []
      )
      items;
  in {
    programs.firefox = {
      enable = true;
      languagePacks = ["en-GB" "da"];

      # https://mozilla.github.io/policy-templates
      policies = {
        SearchEngines = {
          Default = "DuckDuckGo";
          Remove = ["Google" "Amazon.com" "Bing"];
          Add = [
            {
              Name = "AI";
              URLTemplate = "https://ai.jamesst.one?q={searchTerms}";
              Alias = "@ai";
            }
            {
              Name = "ChatGPT";
              URLTemplate = "https://chatgpt.com/?q={searchTerms}";
              Alias = "@chat";
            }
            {
              Name = "Claude";
              URLTemplate = "https://claude.ai/new?q={searchTerms}";
              Alias = "@claude";
            }
            {
              Name = "MyNixOS";
              URLTemplate = "https://mynixos.com/search?q={searchTerms}";
              Alias = "@mn";
            }
            {
              Name = "GitHub";
              URLTemplate = "https://github.com/search?q={searchTerms}";
              Alias = "@gh";
            }
            {
              Name = "GitHub code search";
              URLTemplate = "https://github.com/search?type=code&auto_enroll=true&q=lang%3ANix+{searchTerms}";
              Alias = "@cs";
            }
          ];
        };
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
        };
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableAccounts = true;
        DisableFirefoxScreenshots = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        DontCheckDefaultBrowser = true;
        DisplayBookmarksToolbar = "always";
        DisplayMenuBar = "default-off";
        SearchBar = "unified";

        ExtensionSettings = {
          "*".installation_mode = "blocked";
          # Savvy Time
          "{27dedf38-0ce8-413c-87a8-7f3ae74cfe4d}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/time-zone-converter-savvy-time/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # Linguist
          "support@linguister.io" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/linguist-translator/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # Video Speed Controller
          "{7be2ba16-0f1e-4d93-9ebc-5164397477a9}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/videospeed/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # Privacy Badger
          "jid1-MnnxcxisBPnSXQ@jetpack" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # I still don't care about cookies
          "idcac-pub@guus.ninja" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/istilldontcareaboutcookies/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # Stylus
          "stylus@stylishaddon.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # LanguageTool
          "languagetool-webextension@languagetool.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/languagetool/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # LibRedirect
          "7esoorv3@alefvanoon.anonaddy.me" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/libredirect/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
          # React DevTools
          "react-devtools@reactjs.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/react-devtools/latest.xpi";
            installation_mode = "force_installed";
            default_area = "navbar";
          };
        };

        Preferences = {
          "browser.contentblocking.category" = {
            Value = "strict";
            Status = "locked";
          };
          "extensions.pocket.enabled" = {
            Value = false;
            Status = "locked";
          };
          "extensions.screenshots.disabled" = {
            Value = true;
            Status = "locked";
          };
          "browser.topsites.contile.enabled" = {
            Value = false;
            Status = "locked";
          };
          "browser.formfill.enable" = {
            Value = false;
            Status = "locked";
          };
          "browser.search.suggest.enabled" = {
            Value = false;
            Status = "locked";
          };
          "browser.search.suggest.enabled.private" = {
            Value = false;
            Status = "locked";
          };
          "browser.urlbar.suggest.searches" = {
            Value = false;
            Status = "locked";
          };
          "browser.urlbar.showSearchSuggestionsFirst" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.feeds.section.topstories" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.feeds.snippets" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includePocket" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includeBookmarks" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includeDownloads" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.section.highlights.includeVisited" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.showSponsored" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.system.showSponsored" = {
            Value = false;
            Status = "locked";
          };
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = {
            Value = false;
            Status = "locked";
          };
        };

        ManagedBookmarks = toManagedBookmarks toolbarItems;
      };
    };

    hjem.users.${user} = {
      files = {
        ".mozilla/firefox/profiles.ini".text = ''
          [Profile0]
          Name=${user}
          IsRelative=1
          Path=${user}
          Default=1

          [General]
          StartWithLastProfile=1
          Version=2
        '';
        ".mozilla/firefox/${user}/user.js".text = ''
          user_pref("browser.download.open_pdf_attachments_inline", true);
          user_pref("browser.ml.chat.provider", "https://ai.jamesst.one");
          user_pref("browser.startup.homepage", "http://hermanii:1000");
          user_pref("browser.newtab.url", "http://hermanii:1000");
        '';
      };
      xdg.mime-apps.default-applications = {
        "text/html" = "firefox.desktop";
        "text/xml" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
      };
    };

    persistance.data.directories = [".mozilla"];
    persistance.cache.directories = [".cache/mozilla"];

    preferences.keymap = {
      "SUPER + d"."f".package = pkgs.firefox;
    };
  };

  # tests

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks.firefox = let
      usr = "firefoxtest";
      testPkgs = import pkgs.path {
        inherit system;
        config.allowUnfree = true;
      };
    in
      testPkgs.testers.runNixOSTest {
        name = "firefox";

        nodes.machine = {
          pkgs,
          lib,
          ...
        }: {
          imports = [
            self.nixosModules.base
            self.nixosModules.extra_hjem
            self.nixosModules.desktop
          ];

          preferences.user.name = usr;
          users.users.${usr} = {
            isNormalUser = true;
            extraGroups = ["wheel"];
          };

          # The test VM has no internet access; prevent Firefox from hanging
          # on force-installed extension downloads from addons.mozilla.org.
          programs.firefox.policies.ExtensionSettings = lib.mkForce {
            "*".installation_mode = "blocked";
          };

          boot.kernelModules = ["virtio_gpu"];
          virtualisation.memorySize = 2048;
          virtualisation.qemu.options = ["-vga none -device virtio-gpu-pci"];
          virtualisation.resolution = {
            x = 1920;
            y = 1080;
          };
          environment.variables = {
            LIBGL_ALWAYS_SOFTWARE = "1";
            MESA_LOADER_DRIVER_OVERRIDE = "kms_swrast";
          };
          environment.systemPackages = [pkgs.grim pkgs.imagemagick pkgs.tesseract5];
        };

        enableOCR = true;

        testScript = ''
          start_all()
          machine.wait_for_unit("multi-user.target", timeout=60)

          # Firefox binary is present
          machine.succeed("command -v firefox")

          # System-level policy file is deployed
          machine.succeed("test -f /etc/firefox/policies/policies.json")

          # DuckDuckGo is the default search engine
          machine.succeed(
            "grep -q 'DuckDuckGo' /etc/firefox/policies/policies.json"
          )

          # Telemetry is disabled
          machine.succeed(
            "grep -q 'DisableTelemetry' /etc/firefox/policies/policies.json"
          )

          # "Draw" bookmark is in the ManagedBookmarks policy (policy generation sanity check)
          machine.succeed(
            "grep -q 'Draw' /etc/firefox/policies/policies.json"
          )

          # hjem writes the profile ini for the user
          machine.succeed(
            "test -f /home/${usr}/.mozilla/firefox/profiles.ini"
          )

          # hjem writes user.js for the user
          machine.succeed(
            "test -f /home/${usr}/.mozilla/firefox/${usr}/user.js"
          )

          # Wait for niri Wayland session
          machine.wait_for_file("/run/user/1000/wayland-1", timeout=60)
          machine.wait_until_succeeds("pgrep -u ${usr} niri", timeout=15)

          # Start Firefox in the niri session
          machine.succeed(
            "su - ${usr} -c "
            "'WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 "
            "firefox --no-remote about:blank >/tmp/firefox.log 2>&1 &'"
          )

          # Wait for Firefox process to appear
          machine.wait_until_succeeds("pgrep -u ${usr} firefox", timeout=30)

          # Give Firefox time to render its window (slow with software rendering)
          machine.sleep(30)

          # Grab a diagnostic screenshot and print what OCR sees
          machine.succeed(
            "su - ${usr} -c "
            "'WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 "
            "grim /tmp/debug.png'"
          )
          machine.copy_from_vm("/tmp/debug.png", "")
          print("=== Firefox log ===")
          print(machine.succeed("cat /tmp/firefox.log 2>/dev/null || echo '(no log)'"))
          print("=== OCR full screenshot (PSM 3, 3x) ===")
          print(machine.succeed(
            "convert /tmp/debug.png -scale 300% /tmp/debug3x.png && "
            "tesseract /tmp/debug3x.png /tmp/ocr_out --psm 3 --oem 1 2>/dev/null; "
            "cat /tmp/ocr_out.txt 2>/dev/null || echo '(no output)'"
          ))

          # OCR: retry until "Draw" appears somewhere on screen.
          # Scale 3x and use sparse-text mode (PSM 11) on the full image so we
          # don't have to guess which pixel row the bookmarks toolbar sits on.
          machine.wait_until_succeeds(
            "su - ${usr} -c "
            "'WAYLAND_DISPLAY=wayland-1 XDG_RUNTIME_DIR=/run/user/1000 "
            "grim /tmp/screen.png' && "
            "convert /tmp/screen.png -scale 300% /tmp/screen3x.png && "
            "tesseract /tmp/screen3x.png stdout --psm 11 --oem 1 2>/dev/null "
            "| grep -qi draw",
            timeout=120,
          )
          machine.copy_from_vm("/tmp/screen.png", "")
        '';
      };
  };
}
