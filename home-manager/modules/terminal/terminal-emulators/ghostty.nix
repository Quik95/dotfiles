{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    systemd.enable = true;
    settings = {
      confirm-close-surface = false;
      copy-on-select = false;
      fullscreen = false;
      link-previews = true;
      link-url = true;
      linux-cgroup = "always";
      maximize = true;
      quit-after-last-window-closed = false;
      scrollback-limit = "9999999999999999999";
      window-decoration = true;
      window-inherit-working-directory = true;
      window-save-state = "always";
      window-theme = "ghostty";
    };
  };
}
