{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  # The nixpkgs-side wrapper pins AGENT_BROWSER_EXECUTABLE_PATH to its own
  # chromium with makeCWrapper --set, which wins over anything we export here.
  # Overriding it means rebuilding the package (`agent-browser.override
  # { chromium = ...; }` expects a ${chromium}/bin/chromium layout), so the
  # bundled chromium stays and no dead executablePath setting is kept around.
  agentBrowserEnv = {
    AGENT_BROWSER_HEADED = "1";
    AGENT_BROWSER_NO_XVFB = "1";
  };

  # mcptoon reaches servers over its own catalog rather than the agent's native
  # MCP wiring, so tool schemas never enter the context window. The native entry
  # above stays on the lean "core" profile; the full toolset is only a
  # `mcptoon call agent-browser <tool>` away and costs nothing until used.
  mcptoonConfig = {
    servers = {
      agent-browser = {
        transport = "stdio";
        command = [(lib.getExe llmAgentsPkgs.agent-browser)];
        args = ["mcp" "--tools" "all"];
        env = agentBrowserEnv;
      };
      nixos = {
        transport = "stdio";
        command = ["nix"];
        args = ["run" "github:utensils/mcp-nixos" "--"];
      };
    };
  };

  mcptoonConfigFile = pkgs.writeText "mcptoon-config.json" (builtins.toJSON mcptoonConfig);
  mcptoonConfigPath = "${config.home.homeDirectory}/.mcptoon/config.json";
in {
  home.packages = [
    llmAgentsPkgs.semble
    llmAgentsPkgs.agent-browser
    llmAgentsPkgs.mcptoon
    pkgs.ast-grep
  ];

  programs.mcp = {
    enable = true;
    servers = {
      nixos = {
        command = "nix";
        args = ["run" "github:utensils/mcp-nixos" "--"];
      };
      context7 = {
        url = "https://mcp.context7.com/mcp";
        headers = {
          Authorization = "Bearer {env:CONTEXT7_API_KEY}";
        };
      };
      agent-browser = {
        command = lib.getExe llmAgentsPkgs.agent-browser;
        args = ["mcp" "--tools" "core"];
        env = agentBrowserEnv;
      };
    };
  };

  # agent-browser keeps its own defaults outside the MCP entry, so the bare CLI
  # behaves the same way as the server does.
  home.file.".agent-browser/config.json".text = builtins.toJSON {
    headed = true;
  };

  # `mcptoon add` rewrites this file in place, so keep it outside the Nix store.
  home.activation.installMcptoonConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ ! -v DRY_RUN ]]; then
      install -d -m 0755 "$(dirname "${mcptoonConfigPath}")"
      rm -f "${mcptoonConfigPath}"
      install -m 0644 "${mcptoonConfigFile}" "${mcptoonConfigPath}"
    fi
  '';
}
