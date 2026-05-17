{hostname, ...}: let
  aiAgentsSharedSkills = ''
    Shared AI skill references:
    - Nix best practices: https://skills.sh/0xbigboss/claude-code/nix-best-practices
      Use this skill for Nix, NixOS, Home Manager, flakes, and nixpkgs-related tasks.
  '';

  aiAgentsSystemInstruction = ''
    Current system: ${hostname}

    ${aiAgentsSharedSkills}

    Files under `/nix/store` are approved for read-only exploration and reference.
    Do not modify, replace, or attempt to write anywhere under `/nix/store`.
  '';
  aiAgentsGitContextCommand = builtins.readFile ./commands/git-context.md;
in {
  assertions = [
    {
      assertion = builtins.elem hostname ["sebastian-laptop-hp" "sebastian-laptop-legion"];
      message = "Unsupported hostname '${hostname}'. Expected sebastian-laptop-hp or sebastian-laptop-legion.";
    }
  ];

  _module.args.aiAgentsSystemInstruction = aiAgentsSystemInstruction;
  _module.args.aiAgentsGitContextCommand = aiAgentsGitContextCommand;

  imports = [
    ./claude-code

    ./codex.nix
    ./mcp.nix
    ./opencode.nix
  ];
}
