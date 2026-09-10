{
  pkgs,
  lib,
  config,
  aiAgentsSystemInstruction,
  rtkSource,
  inputs,
  ...
}: let
  wrapWithSecrets = import ./wrap-with-secrets.nix {
    inherit pkgs lib;
  };

  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

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
    skills = import ./skills {inherit inputs;};
    settings = {
      model = "gpt-5.6-luna";
      model_reasoning_effort = "xhigh";
      approval_policy = "never";
      sandbox_mode = "danger-full-access";
      projects = {
        "${config.home.homeDirectory}/Documents/dotfiles".trust_level = "trusted";
      };
      tui = {
        status_line_use_colors = true;
        status_line = [
          "current-dir"
          "git-branch"
          "model-with-reasoning"
          "branch-changes"
          "run-state"
          "context-used"
          "five-hour-limit"
          "weekly-limit"
          "task-progress"
        ];
      };
    };
    context = ''
      ${aiAgentsSystemInstruction}

      ${builtins.readFile "${rtkSource}/hooks/codex/rtk-awareness.md"}
    '';
  };
}
