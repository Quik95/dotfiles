{lib, ...}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";
in {
  config = lib.mkIf isPlasma {
    programs.plasma.panels = [
      {
        floating = true;
        height = 32;
        location = "top";
        # `screen = "all"` depends on Plasma's screenCount at the moment the
        # startup script runs. If the external monitor is detected later, only
        # the primary-screen panel is created and plasma-manager will not rerun
        # the script because the config hash did not change.
        screen = [0 1];
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
          {
            name = "org.muddyblack.aiUsageWidget";
            config.General = {
              claudeEnabled = true;
              openaiEnabled = true;
              sessionsEnabled = false;
              antigravityEnabled = false;
              kiroEnabled = false;
              grokEnabled = false;
              pinnedTab = "claude,openai";
              pollIntervalSec = 60;
              useThemeAccent = true;
            };
          }
          "org.kde.plasma.marginsseparator"
          {
            name = "com.pras.syspeek";
            config.General = {
              leftClickAction = 3; # Do Nothing
              useFixedWidth = false;
              fixedLabelWidth = true; # Fixed Value Width
              itemSpacing = 8;
              # No GPU usage: NVIDIA usage comes from NVML (`nvidia-smi`), and any NVML
              # client polling it keeps the dGPU out of D3cold (~7 W extra on battery).
              panelLayout = "cpu|cpu_temp|ram|swap|upload|download";
            };
          }
          "org.kde.plasma.weather"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.battery"
                "org.kde.plasma.bluetooth"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.volume"
              ];
              configs.battery.showPercentage = true;
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
