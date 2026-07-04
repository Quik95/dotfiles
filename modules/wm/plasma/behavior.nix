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
        # Use KDE's native virtual keyboard (plasma-keyboard, new in 6.7) as
        # KWin's Wayland input method. Package in modules/wm/plasma/nixos.nix.
        Wayland.InputMethod = "/run/current-system/sw/share/applications/org.kde.plasma.keyboard.desktop";
      };

      configFile.kcminputrc.Keyboard.NumLock = 0;

      powerdevil = {
        AC = {
          autoSuspend = {
            action = "sleep";
            idleTimeout = 1800;
          };
          turnOffDisplay = {
            idleTimeout = 180;
          };
          whenLaptopLidClosed = "turnOffScreen";
          inhibitLidActionWhenExternalMonitorConnected = true;
        };
        battery = {
          autoSuspend = {
            action = "sleep";
            idleTimeout = 1800;
          };
          turnOffDisplay = {
            idleTimeout = 180;
          };
          whenLaptopLidClosed = "sleep";
          inhibitLidActionWhenExternalMonitorConnected = true;
        };
        lowBattery = {
          powerProfile = "powerSaving";
        };
      };
    };
  };
}
