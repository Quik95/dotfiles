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
      search = {
        default = "google";
        privateDefault = "google";
        force = true;
        engines = {
          "wikipedia" = {
            name = "Wikipedia (EN)";
            definedAliases = ["@wen"];
            iconMapObj."16" = "https://mycroftproject.com/updateos.php/id0/wikipedia_en_ssl.ico";
            urls = [
              {
                template = "https://en.wikipedia.org/wiki/Special:Search";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "youtube" = {
            name = "YouTube";
            definedAliases = ["@yt"];
            iconMapObj."16" = "https://mycroftproject.com/updateos.php/id0/youtube.ico";
            urls = [
              {
                template = "https://youtube.com/results";
                params = [
                  {
                    name = "search_query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "home-manager-options" = {
            name = "Home Manager Options";
            definedAliases = ["@hm"];
            iconMapObj."16" = "https://home-manager-options.extranix.com/images/favicon.png";
            urls = [
              {
                template = "https://home-manager-options.extranix.com";
                params = [
                  {
                    name = "release";
                    value = "master";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "mycroft-project" = {
            name = "Mycroft Project";
            definedAliases = ["@mycroft"];
            iconMapObj."16" = "https://mycroftproject.com/favicon.ico";
            urls = [
              {
                template = "https://mycroftproject.com/search-engines.html";
                params = [
                  {
                    name = "name";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "arch-wiki" = {
            name = "Arch Wiki";
            definedAliases = ["@arch"];
            iconMapObj."16" = "https://mycroftproject.com/updateos.php/id0/archlinux_wiki_ssl.png";
            urls = [
              {
                template = "https://wiki.archlinux.org/index.php/Special:Search";
                params = [
                  {
                    name = "go";
                    value = "Go";
                  }
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "github" = {
            name = "GitHub";
            definedAliases = ["@git"];
            iconMapObj."16" = "https://mycroftproject.com/updateos.php/id0/github93het.ico";
            urls = [
              {
                template = "https://github.com/search";
                params = [
                  {
                    name = "q";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "nixpkgs-unstable" = {
            name = "NixOS Packages (unstable)";
            definedAliases = ["@nix"];
            iconMapObj."16" = "https://mycroftproject.com/updateos.php/id0/nixpkgs-unstable-ver.ico";
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
          };
          "nixpkgs-pr" = {
            name = "NixOS nixpkgs Pull Requests";
            definedAliases = ["@nixpr"];
            iconMapObj."16" = "https://mycroftproject.com/updateos.php/id0/github93het.ico";
            urls = [
              {
                template = "https://github.com/NixOS/nixpkgs/pulls";
                params = [
                  {
                    name = "q";
                    value = "sort:updated-desc is:pr is:open {searchTerms}";
                  }
                ];
              }
            ];
          };
        };
      };

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

        # UI improvements
        "browser.tabs.loadInBackground" = true;
        "browser.tabs.closeWindowWithLastTab" = false;
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
      };
    };
  };
}
