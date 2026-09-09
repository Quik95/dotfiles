{
  config,
  pkgs,
  inputs,
  ...
}: let
  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [llmAgentsPkgs.semble pkgs.ast-grep];

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
    };
  };
}
