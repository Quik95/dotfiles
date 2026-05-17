{
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
