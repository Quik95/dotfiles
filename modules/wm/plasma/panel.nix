{
  lib,
  hostname,
  ...
}: {
  config = lib.mkIf (hostname == "sebastian-laptop-legion") {
    programs.plasma.panels = [
      {
        floating = true;
        height = 32;
        location = "top";
        screen = "all";
        widgets = [
          "org.kde.plasma.kickoff"
          {
            iconTasks = {
              iconsOnly = false;
              launchers = [
                "applications:systemsettings.desktop"
                "applications:org.kde.dolphin.desktop"
                "applications:com.mitchellh.ghostty.desktop"
                "applications:firefox.desktop"
                "applications:mpv.desktop"
                "applications:dev.zed.Zed.desktop"
                "applications:org.kde.kate.desktop"
              ];
              behavior.showTasks = {
                onlyInCurrentScreen = true;
                onlyInCurrentDesktop = true;
              };
              behavior.middleClickAction = "close";
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            name = "com.pras.syspeek";
            config.General = {
              useFixedWidth = true;
              itemSpacing = 26;
              widgetWidth = 380;
            };
          }
          "org.kde.plasma.weather"
          {
            battery.showPercentage = true;
          }
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              hidden = [
                "org.kde.plasma.battery"
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
