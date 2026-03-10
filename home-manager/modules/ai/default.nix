{hostname, ...}: let
  aiAgentsSystemInstruction = ''
    Current system: ${hostname}
  '';
in {
  assertions = [
    {
      assertion = builtins.elem hostname ["sebastian-laptop-hp" "sebastian-laptop-loq"];
      message = "Unsupported hostname '${hostname}'. Expected sebastian-laptop-hp or sebastian-laptop-loq.";
    }
  ];

  _module.args.aiAgentsSystemInstruction = aiAgentsSystemInstruction;

  imports = [
    ./claudecode.nix
    ./codex.nix
    ./mcp.nix
    ./opencode.nix
  ];
}
