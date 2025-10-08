{
  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    enableGitIntegration = true;
    settings = {
      copy_on_select = "no";
      disable_ligatures = "never";
      enable_audio_bell = "no";
      paste_actions = "quote-urls-at-prompt";
      scrollback_lines = 1000000;
      scrollback_pager = "bat";
      strip_trailing_spaces = "smart";
      sync_to_monitor = "yes";
      tab_bar_style = "powerline";
    };
  };
}
