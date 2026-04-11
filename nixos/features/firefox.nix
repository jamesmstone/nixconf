{self, ...}: {
  flake.nixosModules.firefox = {
    pkgs,
    config,
    lib,
    ...
  }: let
    user = config.preferences.user.name;

    bookmarksToHtml = items: let
      e = lib.strings.escapeXML;
      itemToHtml = item:
        if item ? bookmarks
        then ''
          <DT><H3${lib.optionalString (item.toolbar or false) " PERSONAL_TOOLBAR_FOLDER=\"true\""}>${e item.name}</H3>
          <DL><p>
          ${lib.concatMapStrings itemToHtml item.bookmarks}</DL><p>
        ''
        else "<DT><A HREF=\"${e item.url}\">${e item.name}</A>\n";
    in ''
      <!DOCTYPE NETSCAPE-Bookmark-file-1>
      <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
      <TITLE>Bookmarks</TITLE>
      <H1>Bookmarks Menu</H1>
      <DL><p>
      ${lib.concatMapStrings itemToHtml items}</DL><p>
    '';

    bookmarksHtml =
      pkgs.writeText "firefox-bookmarks.html"
      (bookmarksToHtml (import ./_bookmarks.nix));
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
          user_pref("browser.bookmarks.file", "${bookmarksHtml}");
          user_pref("browser.bookmarks.restore_default_bookmarks", false);
          user_pref("browser.places.importBookmarksHTML", true);
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
}
