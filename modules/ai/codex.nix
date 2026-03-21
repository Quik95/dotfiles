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
  codexHome = "${config.xdg.configHome}/codex";
  codexSettings = {
    model = "gpt-5.3-codex";
    mcp_servers =
      lib.mapAttrs (
        _: server:
          {
            enabled = true;
          }
          // lib.optionalAttrs (server ? command) {
            inherit (server) command;
          }
          // lib.optionalAttrs (server ? args) {
            inherit (server) args;
          }
          // lib.optionalAttrs (server ? url) {
            inherit (server) url;
          }
          // lib.optionalAttrs (server ? headers) {
            http_headers = server.headers;
          }
      )
      config.programs.mcp.servers;
  };
  codexSettingsToml = (pkgs.formats.toml {}).generate "codex-config.toml" codexSettings;

  codexWrapped = wrapWithSecrets {
    pkg = llmAgentsPkgs.codex;
    binary = "codex";
    vars = {
      CODEX_ZAI_API_KEY = config.sops.secrets."CODEX_ZAI_API_KEY".path;
      CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
    };
  };
in {
  home.sessionVariables = {
    CODEX_HOME = codexHome;
  };

  xdg.configFile."codex/AGENTS.md".text = ''
    ${aiAgentsSystemInstruction}
  '';

  xdg.configFile."codex/config.toml".source = codexSettingsToml;

  programs.codex = {
    enable = true;
    package = codexWrapped;
    # Home Manager writes programs.codex.settings to ~/.codex/config.yaml and
    # ignores CODEX_HOME for that path, so we manage config.toml via xdg.configFile.
    enableMcpIntegration = false;
    settings = lib.mkForce {};
  };
}
