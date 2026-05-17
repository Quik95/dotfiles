{
  pkgs,
  lib,
  config,
  aiAgentsSystemInstruction,
  llm-agents,
  ...
}: let
  wrapWithSecrets = import ./wrap-with-secrets.nix {
    inherit pkgs lib;
  };

  llmAgentsPkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  codexWrapped = wrapWithSecrets {
    pkg = llmAgentsPkgs.codex;
    binary = "codex";
    vars = {
      CODEX_ZAI_API_KEY = config.sops.secrets."CODEX_ZAI_API_KEY".path;
      CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
    };
  };
in {
  programs.codex = {
    enable = true;
    package = codexWrapped;
    enableMcpIntegration = true;
    settings = {
      model = "gpt-5.5";
      tui = {
        status_line_use_colors = true;
        status_line = [
          "branch-changes"
          "run-state"
          "context-used"
          "five-hour-limit"
          "weekly-limit"
          "task-progress"
        ];
      };
    };
    context = aiAgentsSystemInstruction;
  };
}
