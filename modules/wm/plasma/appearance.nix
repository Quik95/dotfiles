{
  lib,
  hostname,
  ...
}: let
  purpleRainAccent = "128,91,181";
in {
  config = lib.mkIf (hostname == "sebastian-laptop-legion") {
    programs.plasma = {
      workspace = {
        clickItemTo = "select";
        theme = "breeze-dark";
        colorScheme = "BreezeDark";
        wallpaperPictureOfTheDay.provider = "bing";
      };

      fonts = {
        general = {
          family = "Noto Sans";
          pointSize = 10;
        };
        fixedWidth = {
          family = "Hack";
          pointSize = 10;
        };
        small = {
          family = "Noto Sans";
          pointSize = 8;
        };
        toolbar = {
          family = "Noto Sans";
          pointSize = 10;
        };
        menu = {
          family = "Noto Sans";
          pointSize = 10;
        };
        windowTitle = {
          family = "Noto Sans";
          pointSize = 10;
        };
      };

      configFile = {
        kdeglobals = {
          KDE = {
            SingleClick = false;
          };
          General = {
            AccentColor = purpleRainAccent;
            LastUsedCustomAccentColor = purpleRainAccent;
            accentColorFromWallpaper = false;
          };
        };

        "plasma-localerc" = {
          Formats = {
            LANG = "en_US.UTF-8";
            LC_ADDRESS = "pl_PL.UTF-8";
            LC_IDENTIFICATION = "pl_PL.UTF-8";
            LC_MEASUREMENT = "pl_PL.UTF-8";
            LC_MONETARY = "pl_PL.UTF-8";
            LC_NAME = "pl_PL.UTF-8";
            LC_NUMERIC = "pl_PL.UTF-8";
            LC_PAPER = "pl_PL.UTF-8";
            LC_TELEPHONE = "pl_PL.UTF-8";
            LC_TIME = "pl_PL.UTF-8";
          };
        };
      };
    };
  };
}
