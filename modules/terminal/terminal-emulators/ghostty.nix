{
  config,
  lib,
  pkgs,
  ...
}: {
  # Ghostty <= 1.3.1 sends READY=1 before installing its SIGUSR2 handler; systemd >= 262
  # then refuses the Type=notify-reload unit, so the first D-Bus launch fails.
  # Fixed upstream in https://github.com/ghostty-org/ghostty/pull/14399.
  xdg.configFile."systemd/user/app-com.mitchellh.ghostty.service.d/notify-race.conf" = lib.mkIf (lib.versionOlder config.programs.ghostty.package.version "1.3.2") {
    text = ''
      [Service]
      Type=dbus
      ExecReload=${pkgs.coreutils}/bin/kill -USR2 $MAINPID
    '';
  };

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    systemd.enable = true;
    settings = {
      app-notifications = "no-clipboard-copy,config-reload";
      clipboard-trim-trailing-spaces = true;
      confirm-close-surface = false;
      copy-on-select = false;
      fullscreen = false;
      keybind = "ctrl+backspace=text:\\x17";
      link-previews = true;
      link-url = true;
      linux-cgroup = "always";
      maximize = true;
      notify-on-command-finish = "unfocused";
      notify-on-command-finish-after = "30s";
      quit-after-last-window-closed = false;
      resize-overlay = "always";
      scrollback-limit = "9999999999999999999";
      selection-clear-on-copy = true;
      unfocused-split-opacity = 0.8;
      window-decoration = true;
      window-inherit-working-directory = true;
      window-padding-balance = true;
      window-save-state = "always";
      window-subtitle = "working-directory";
      window-theme = "ghostty";
    };
  };
}
