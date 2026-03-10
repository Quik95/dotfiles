{hostname, ...}: let
  aiAgentsSystemInstruction = ''
    Current system: ${hostname}
  '';
  aiAgentsGitContextCommand = builtins.readFile ./commands/git-context.md;
in {
  assertions = [
    {
      assertion = builtins.elem hostname ["sebastian-laptop-hp" "sebastian-laptop-loq"];
      message = "Unsupported hostname '${hostname}'. Expected sebastian-laptop-hp or sebastian-laptop-loq.";
    }
  ];

  _module.args.aiAgentsSystemInstruction = aiAgentsSystemInstruction;
  _module.args.aiAgentsGitContextCommand = aiAgentsGitContextCommand;

  imports = [
    ./claudecode.nix
    ./codex.nix
    ./mcp.nix
    ./opencode.nix
  ];
}
