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
          CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}";
        };
      };
    };
  };

  systemd.user.services.mcp-env-loader = {
    Unit = {
      Description = "Load MCP environment variables from sops";
      Before = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = config.sops.secrets.mcp-env.path;

      ExecStart = "${pkgs.systemd}/bin/systemctl --user import-environment CONTEXT7_API_KEY";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
