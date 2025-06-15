{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    settings = {
      scrollback-limit = "9999999999999999999";
      fullscreen = false;
      window-inherit-working-directory = true;
      window-decoration = true;
      window-theme = "ghostty";
      window-save-state = "always";
      copy-on-select = false;
      confirm-close-surface = false;
      quit-after-last-window-closed = false;
      linux-cgroup = "always";
    };
  };
}
