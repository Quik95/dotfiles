{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  cloakbrowser = inputs.cloakbrowser.packages.${pkgs.stdenv.hostPlatform.system}.cloakbrowserChromium;
  agentBrowserProfile = "${config.xdg.stateHome}/agent-browser/profile";
  agentBrowserEnv = {
    AGENT_BROWSER_HEADED = "1";
    AGENT_BROWSER_NO_XVFB = "1";
    AGENT_BROWSER_EXECUTABLE_PATH = lib.getExe cloakbrowser;
    AGENT_BROWSER_PROFILE = agentBrowserProfile;
  };
in {
  home.packages = [
    llmAgentsPkgs.semble
    pkgs.agent-browser
    cloakbrowser
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
        command = lib.getExe pkgs.agent-browser;
        args = ["mcp" "--tools" "core"];
        env = agentBrowserEnv;
      };
    };
  };

  # agent-browser keeps its own defaults outside the MCP entry, so the bare CLI
  # behaves the same way as the server does.
  home.file.".agent-browser/config.json".text = builtins.toJSON {
    headed = true;
    executablePath = lib.getExe cloakbrowser;
    profile = agentBrowserProfile;
  };
}
