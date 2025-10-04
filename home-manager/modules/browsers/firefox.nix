{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf (config.myHomeManager.browsers.enable && config.myHomeManager.browsers.firefox.enable) {
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
                template = "https://mycroftproject.com/search-engines.html?name={searchTerms}";
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
                template = "https://wiki.archlinux.org/index.php/Special:Search?go=Go&amp;search={searchTerms}";
                params = [
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
                template = "https://github.com/search?q={searchTerms}";
                params = [
                  {
                    name = "search";
                    value = "{searchParams}";
                  }
                ];
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
  };
}
