{
  config,
  pkgs,
  ...
}: {
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
