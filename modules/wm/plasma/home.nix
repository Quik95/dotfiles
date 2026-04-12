{
  lib,
  hostname,
  ...
}:
lib.mkIf (hostname == "sebastian-laptop-legion") {
  programs.plasma = {
    enable = true;

    workspace = {
      clickItemTo = "select";
    };

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
    };

    configFile = {
      kwinrc = {
        Windows = {
          FocusPolicy = "FocusFollowsMouse";
        };
        Desktops = {
          Number = 1;
        };
      };
      kdeglobals = {
        KDE = {
          SingleClick = false;
        };
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

    configFile.kwinrc.NightColor = {
      Active = true;
      Mode = 0;
    };

    panels = [
      {
        location = "bottom";
        widgets = [
          "org.kde.plasma.kickoff"
          {
            iconTasks = {
              launchers = [
                "applications:org.kde.dolphin.desktop"
                "applications:com.mitchellh.ghostty.desktop"
                "applications:firefox.desktop"
                "applications:mpv.desktop"
                "applications:dev.zed.Zed.desktop"
                "applications:org.kde.kate.desktop"
              ];
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
            };
          }
          {
            digitalClock = {
              time.format = "24h";
            };
          }
        ];
      }
    ];
  };
}
