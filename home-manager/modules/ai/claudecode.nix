{
  pkgs,
  config,
  ...
}: {
  home.file = import ./skills {
    inherit pkgs;
    basePath = "${config.home.homeDirectory}/.claude/skills";
  };

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };
}
