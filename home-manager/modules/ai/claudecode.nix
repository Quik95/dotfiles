{
  pkgs,
  lib,
  config,
  llm-agents,
  ...
}: let
  wrapWithSecrets = import ./wrap-with-secrets.nix {
    inherit pkgs lib;
  };

  llmAgentsPkgs = llm-agents.packages.${pkgs.system};

  claudeWrapped = wrapWithSecrets {
    pkg = llmAgentsPkgs.claude-code;
    binary = "claude";
    vars = {
      CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
    };
  };
in {
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
    package = claudeWrapped;
    enableMcpIntegration = true;
  };
}
