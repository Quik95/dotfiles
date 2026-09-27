let
  username = "sebastian";
in {
  inherit username;
  homeDirectory = "/home/${username}";

  editor = "nvim";
  visual = "nvim";
  terminal = "ghostty";
  pager = "bat";
  browser = "firefox";
  claudeConfigDir = config: "${config.xdg.configHome}/claude-code";
}
