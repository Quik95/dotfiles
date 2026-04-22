{
  lib,
  hostname,
  ...
}: {
  config = lib.mkIf (hostname == "sebastian-laptop-legion") {
    programs.plasma = {
      shortcuts = {
        kwin = {
          "Window Close" = "Alt+Q";
        };
        "org.kde.spectacle.desktop" = {
          "RectangularRegionScreenShot" = "Ctrl+Delete";
        };
      };

      kwin = {
        edgeBarrier = 0;
        cornerBarrier = false;
        nightLight = {
          enable = true;
          mode = "automatic";
        };
      };

      input.keyboard = {
        layouts = [
          {layout = "pl";}
        ];
        repeatDelay = 200;
        repeatRate = 66.67;
      };

      input.touchpads = [
        {
          name = "FTCS0038:00 2808:0106 Touchpad";
          vendorId = "2808";
          productId = "0106";
          naturalScroll = true;
        }
      ];

      configFile.kwinrc = {
        Windows = {
          FocusPolicy = "FocusFollowsMouse";
        };
        Desktops = {
          Number = 1;
        };
      };

      powerdevil = {
        AC = {
          autoSuspend = {
            action = "sleep";
            idleTimeout = 1800;
          };
          turnOffDisplay = {
            idleTimeout = 180;
          };
        };
        battery = {
          autoSuspend = {
            action = "sleep";
            idleTimeout = 1800;
          };
          turnOffDisplay = {
            idleTimeout = 180;
          };
        };
        lowBattery = {
          powerProfile = "powerSaving";
        };
      };
    };
  };
}
