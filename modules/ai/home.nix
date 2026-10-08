{hostname, ...}: let
  aiAgentsSystemInstruction = ''
    Current system: ${hostname}

    Files under `/nix/store` are approved for read-only exploration and reference.
    Do not modify, replace, or attempt to write anywhere under `/nix/store`.

    ## Browser Automation

    Use `agent-browser` for web automation. Run `agent-browser --help` for all commands.

    Core workflow:

    1. `agent-browser open <url>` - Navigate to page
    2. `agent-browser snapshot -i` - Get interactive elements with refs (@e1, @e2)
    3. `agent-browser click @e1` / `fill @e2 "text"` - Interact using refs
    4. Re-snapshot after page changes
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

    ./agy.nix
    ./codex.nix
    ./lsp.nix
    ./mcp.nix
    ./skills
  ];
}
