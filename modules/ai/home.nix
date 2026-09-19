{
  hostname,
  inputs,
  pkgs,
  ...
}: let
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
in {
  assertions = [
    {
      assertion = builtins.isString hostname && hostname != "";
      message = "A non-empty hostname is required for AI agent instructions.";
    }
  ];

  _module.args.aiAgentsSystemInstruction = aiAgentsSystemInstruction;
  imports = [
    ./claude-code

    inputs.omp.homeManagerModules.default

    ./codex.nix
    ./lsp.nix
    ./maki.nix
    ./mcp.nix
  ];

  programs.omp = {
    enable = true;
    package = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
    settings = {
      startup.quiet = true;
      theme.dark = "titanium";
    };
  };
}
