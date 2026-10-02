{hostname, ...}: let
  aiAgentsSystemInstruction = ''
    Current system: ${hostname}

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
    ./omp-settings.nix

    ./codex.nix
    ./lsp.nix
    ./mcp.nix
    ./skills
  ];
}
