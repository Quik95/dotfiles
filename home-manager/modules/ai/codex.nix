{config, ...}: {
  home.sessionVariables = {
    CODEX_HOME = "${config.xdg.configHome}/codex";
  };

  programs.codex = {
    enable = true;
    settings = {
      model = "gpt-5.3-codex";
    };
  };
}
