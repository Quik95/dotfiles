{
  pkgs,
  config,
  ...
}: {
  home.file = import ./skills {
    inherit pkgs;
    basePath = "${config.home.homeDirectory}/.claude/skills";
  };

  home.packages = with pkgs; [
    omnisharp-roslyn
    rust-analyzer
  ];

  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
  };
}
