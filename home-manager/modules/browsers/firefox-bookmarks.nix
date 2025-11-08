let
  # Helper function to create a search engine with less boilerplate
  mkSearchEngine = {
    name,
    alias,
    icon,
    template,
    queryParam,
    extraParams ? [],
  }: {
    inherit name;
    definedAliases = ["@${alias}"];
    iconMapObj."16" = icon;
    urls = [
      {
        inherit template;
        params =
          [
            {
              name = queryParam;
              value = "{searchTerms}";
            }
          ]
          ++ extraParams;
      }
    ];
  };
in {
  default = "google";
  privateDefault = "google";
  force = true;
  engines = {
    "wikipedia" = mkSearchEngine {
      name = "Wikipedia (EN)";
      alias = "wen";
      icon = "https://mycroftproject.com/updateos.php/id0/wikipedia_en_ssl.ico";
      template = "https://en.wikipedia.org/wiki/Special:Search";
      queryParam = "search";
    };

    "youtube" = mkSearchEngine {
      name = "YouTube";
      alias = "yt";
      icon = "https://mycroftproject.com/updateos.php/id0/youtube.ico";
      template = "https://youtube.com/results";
      queryParam = "search_query";
    };

    "home-manager-options" = mkSearchEngine {
      name = "Home Manager Options";
      alias = "hm";
      icon = "https://home-manager-options.extranix.com/images/favicon.png";
      template = "https://home-manager-options.extranix.com";
      queryParam = "query";
      extraParams = [
        {
          name = "release";
          value = "master";
        }
      ];
    };

    "mycroft-project" = mkSearchEngine {
      name = "Mycroft Project";
      alias = "mycroft";
      icon = "https://mycroftproject.com/favicon.ico";
      template = "https://mycroftproject.com/search-engines.html";
      queryParam = "name";
    };

    "arch-wiki" = mkSearchEngine {
      name = "Arch Wiki";
      alias = "arch";
      icon = "https://mycroftproject.com/updateos.php/id0/archlinux_wiki_ssl.png";
      template = "https://wiki.archlinux.org/index.php/Special:Search";
      queryParam = "search";
      extraParams = [
        {
          name = "go";
          value = "Go";
        }
      ];
    };

    "github" = mkSearchEngine {
      name = "GitHub";
      alias = "git";
      icon = "https://mycroftproject.com/updateos.php/id0/github93het.ico";
      template = "https://github.com/search";
      queryParam = "q";
    };

    "nixpkgs-unstable" = mkSearchEngine {
      name = "NixOS Packages (unstable)";
      alias = "nix";
      icon = "https://mycroftproject.com/updateos.php/id0/nixpkgs-unstable-ver.ico";
      template = "https://search.nixos.org/packages";
      queryParam = "query";
      extraParams = [
        {
          name = "channel";
          value = "unstable";
        }
      ];
    };

    "nixpkgs-pr" = mkSearchEngine {
      name = "NixOS nixpkgs Pull Requests";
      alias = "nixpr";
      icon = "https://mycroftproject.com/updateos.php/id0/github93het.ico";
      template = "https://github.com/NixOS/nixpkgs/pulls";
      queryParam = "q";
      extraParams = [
        {
          name = "q";
          value = "sort:updated-desc is:pr is:open {searchTerms}";
        }
      ];
    };
  };
}
