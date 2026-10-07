{
  pkgs,
  lib,
  config,
  aiAgentsSystemInstruction,
  ...
}: let
  wrapWithSecrets = import ./wrap-with-secrets.nix {inherit pkgs lib;};
  context7 = wrapWithSecrets {
    pkg = pkgs.context7-mcp;
    binary = "context7-mcp";
    vars.CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
  };
in {
  programs.antigravity-cli = {
    enable = true;
    enableMcpIntegration = true;
    # Keep the API key in a runtime-loaded SOPS file, not remote headers.
    mcpServers.context7 = lib.mkForce {
      command = lib.getExe' context7 "context7-mcp";
    };
    context.AGENTS = aiAgentsSystemInstruction;
    settings = {
      toolPermission = "always-proceed";
      artifactReviewPolicy = "always-proceed";
      enableTerminalSandbox = false;
      allowNonWorkspaceAccess = true;
      colorScheme = "terminal";
    };
  };

  # agy replaces this symlink when persisting preferences. Restore the
  # declarative settings on activation, including after an interactive save.
  home.file.".gemini/antigravity-cli/settings.json".force = true;
}
