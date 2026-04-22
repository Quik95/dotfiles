{
  pkgs,
  lib,
  config,
  aiAgentsSystemInstruction,
  aiAgentsGitContextCommand,
  llm-agents,
  ...
}: let
  wrapWithSecrets = import ./wrap-with-secrets.nix {
    inherit pkgs lib;
  };

  llmAgentsPkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

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
    commands = {
      git-context = aiAgentsGitContextCommand;
    };
    memory.text = ''
      ${aiAgentsSystemInstruction}
    '';
    settings = {
      permissions = {
        additionalDirectories = ["/nix/store"];
        allow = [
          "Read(//nix/store)"
          "Read(//nix/store/**)"
          "LS(//nix/store)"
          "LS(//nix/store/**)"
          "Glob(//nix/store/**)"
          "Grep(//nix/store/**)"
        ];
        deny = [
          "Edit(//nix/store/**)"
          "Write(//nix/store/**)"
          "MultiEdit(//nix/store/**)"
        ];
      };
      sandbox.filesystem.denyWrite = ["/nix/store"];
    };
  };
}
