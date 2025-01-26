{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    themeFile = "Catppuccin-Frappe";
    font = {
      size = 16;
      name = "DejaVuSansMono";
    };
    settings = {
      disable_ligatures = "never";
      scrollback_lines = 1000000;
      scrollback_pager = "bat";
      copy_on_select = "no";
      paste_actions = "quote-urls-at-prompt";
      strip_trailing_spaces = "smart";
      sync_to_monitor = "yes";
      enable_audio_bell = "no";
      tab_bar_style = "powerline";
      background_opacity = 0.9;
      cursor_trail = 1;
    };
  };
}
