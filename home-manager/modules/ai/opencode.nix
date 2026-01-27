{
  pkgs,
  config,
  ...
}: let
  fake-xdg-open = pkgs.writeScriptBin "xdg-open" ''
    #!/usr/bin/env bash
    exit 0
  '';
in {
  home.file = import ./skills {
    inherit pkgs;
    basePath = "${config.xdg.configHome}/opencode/skills";
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      lsp = {
        html = {
          command = ["${pkgs.superhtml}/bin/superhtml lsp"];
          extensions = [".html" ".shtml" ".htm"];
        };
        json = {
          command = ["${pkgs.vscode-json-languageserver}/bin/vscode-json-language-server --stdio"];
          extensions = [".json" ".jsonc"];
        };
        nixd = {
          command = ["${pkgs.nixd}/bin/nixd"];
          extensions = [".nix"];
        };
        dotnet = {
          command = ["${pkgs.omnisharp-roslyn}/bin/OmniSharp"];
          extensions = [".cs" ".csx"];
        };
      };
      formatter = {
        nixfmt = {
          command = ["${pkgs.alejandra}" "--quiet" "$FILE"];
        };
      };
      server = {
        hostname = "127.0.0.1";
        port = 4096;
      };
      keybinds = {
        model_list = "alt+p";
      };
      plugin = ["opencode-gemini-auth@latest"];
    };
  };

  # OpenCode module has built-in support for starting this server, but it auto opens
  # the web interface, which is stupid and I don't want that
  systemd.user.services.opencode-web = {
    Unit = {
      Description = "OpenCode Web Service";
      After = ["network.target"];
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.opencode}/bin/opencode web";
      Environment = [
        "OPENCODE_DISABLE_CLAUDE_CODE=1"
        "PATH=${fake-xdg-open}/bin:/run/current-system/sw/bin"
      ];
      Restart = "on-failure";
      RestartSec = "5s";

      PrivateDevices = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectClock = true;
      ProtectHostname = true;
      ProtectControlGroups = true;
      SystemCallArchitectures = "native";
      LockPersonality = true;
      RestrictRealtime = true;
    };

    Install = {
      WantedBy = ["default.target"];
    };
  };
}
