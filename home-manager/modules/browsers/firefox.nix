{pkgs, ...}: {
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-beta;
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
            urls = [
              {
                template = "https://en.wikipedia.org/wiki/Special:Search";
                params = [
                  {
                    name = "search";
                    value = "{searchTerms}";
                  }
                ];
                definedAliases = ["@wen"];
              }
            ];
          };
          "youtube" = {
            urls = [
              {
                template = "https://youtube.com/results";
                params = [
                  {
                    name = "search_query";
                    value = "{searchTerms}";
                  }
                ];
                definedAliases = ["@yt"];
              }
            ];
          };
          "home-manager-options" = {
            urls = [
              {
                template = "https://home-manager-options.extranix.com/?query=firefox+search&release=master";
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
                definedAliases = ["@hm"];
              }
            ];
          };
        };
      };

      settings = {
        "browser.shell.checkDefaultBrowser" = false;
        "browser.startup.homepage" = "about:blank";
        "browser.urlbar.trimURLs" = true;
        "browser.search.suggest.enabled" = true;
        "ui.key.menuAccessKey" = 0;
      };
    };
  };
}
