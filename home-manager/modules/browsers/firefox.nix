{pkgs, lib, ...}: let
  dictionaries = with pkgs.hunspellDicts; [
    pl_PL
    en_GB-large
  ];
in {
  home.packages = with pkgs; [
    hunspell
  ] ++ dictionaries;

  home.sessionVariables = {
    DICPATH = lib.concatMapStringsSep ":" (dict: "${dict}/share/hunspell") dictionaries;
  };

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    languagePacks = ["en-GB" "pl"];
    policies = {
      DefaultDownloadDirectory = "/tmp";
      DontCheckDefaultBrowser = true;
      HardwareAcceleration = true;
      NoDefaultBookmarks = true;
      ExtensionUpdate = true;
      NetworkPrediction = true;
      DisableAppUpdate = true;
      DisplayBookmarksToolbar = "newtab";
      Searchbar = "unified";
    };

    profiles.default = {
      isDefault = true;
      name = "default";
      search = import ./firefox-bookmarks.nix;

      settings = {
        # General settings
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.urlbar.trimURLs" = true;
        "browser.search.suggest.enabled" = true;
        "ui.key.menuAccessKey" = 0;
        "pdfjs.enableHighlightFloatingButton" = false;

        # Performance
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.force-enabled" = true;

        # Wayland-specific improvements
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        "widget.use-xdg-desktop-portal.mime-handler" = 1;

        # Security
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;
        "dom.security.https_only_mode_exceptions" = "opencode.local";

        # Network
        "network.trr.mode" = 2;
        "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";
        "network.trr.bootstrapAddress" = "1.1.1.1";
        "network.dns.echconfig.enabled" = true;

        # UI improvements
        "browser.tabs.loadInBackground" = true;
        "browser.tabs.closeWindowWithLastTab" = true;
        "browser.tabs.warnOnClose" = false;
        "browser.tabs.warnOnCloseOtherTabs" = false;
        "browser.download.useDownloadDir" = false;
        "browser.toolbars.bookmarks.showOtherBookmarks" = false;
        "sidebar.visibility" = "hide-sidebar-button";

        # Address bar suggestions
        "browser.urlbar.suggest.bookmark" = true;
        "browser.urlbar.suggest.history" = true;
        "browser.urlbar.suggest.openpage" = true;
        "browser.urlbar.suggest.topsites" = true;
        "browser.urlbar.suggest.engines" = true;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

        # Navbar
        "browser.uiCustomization.state" = {
          placements = {
            "widget-overflow-fixed-list" = [];
            "unified-extensions-area" = [
              "gdpr_cavi_au_dk-browser-action"
              "myallychou_gmail_com-browser-action"
              "_7be2ba16-0f1e-4d93-9ebc-5164397477a9_-browser-action"
              "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
              "wappalyzer_crunchlabz_com-browser-action"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
              "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
              "_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action"
            ];
            "nav-bar" = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "vertical-spacer"
              "customizableui-special-spring1"
              "urlbar-container"
              "customizableui-special-spring2"
              "downloads-button"
              "screenshot-button"
              "unified-extensions-button"
              "fxa-toolbar-menu-button"
              "reset-pbm-toolbar-button"
              "ublock0_raymondhill_net-browser-action"
              "myallychou_gmail_com-browser-action"
              "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
            ];
            "toolbar-menubar" = [
              "menubar-items"
            ];
            "TabsToolbar" = [
              "firefox-view-button"
              "tabbrowser-tabs"
              "new-tab-button"
              "alltabs-button"
            ];
            "vertical-tabs" = [];
            "PersonalToolbar" = [
              "personal-bookmarks"
            ];
          };
          seen = [
            "gdpr_cavi_au_dk-browser-action"
            "myallychou_gmail_com-browser-action"
            "_7be2ba16-0f1e-4d93-9ebc-5164397477a9_-browser-action"
            "_a4c4eda4-fb84-4a84-b4a1-f7c1cbf2a1ad_-browser-action"
            "ublock0_raymondhill_net-browser-action"
            "wappalyzer_crunchlabz_com-browser-action"
            "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action"
            "_aecec67f-0d10-4fa7-b7c7-609a2db280cf_-browser-action"
            "jid0-adyhmvsp91nuo8prv0mn2vkeb84_jetpack-browser-action"
            "sponsorblocker_ajay_app-browser-action"
            "_2e5ff8c8-32fe-46d0-9fc8-6b8986621f3c_-browser-action"
            "developer-button"
            "screenshot-button"
          ];
          dirtyAreaCache = [
            "unified-extensions-area"
            "nav-bar"
            "vertical-tabs"
            "toolbar-menubar"
            "TabsToolbar"
            "PersonalToolbar"
          ];
          currentVersion = 23;
          newElementCount = 2;
        };
        # Spellcheck
        "spellcheck.dictionary" = "pl,en-GB";
        "layout.spellcheckDefault" = 2;

        # Dark theme
        "ui.systemUsesDarkTheme" = 1;
        "browser.theme.dark-private-windows" = true;
        "browser.theme.toolbar-theme" = 0;
        "extensions.activeThemeID" = "firefox-compact-dark@mozilla.org";
        "layout.css.prefers-color-scheme.content-override" = 0;
      };
    };
  };
}
