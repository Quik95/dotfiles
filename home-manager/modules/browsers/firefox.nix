{pkgs, ...}: {
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
