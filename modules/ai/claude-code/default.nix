{
  pkgs,
  lib,
  config,
  aiAgentsSystemInstruction,
  aiAgentsLspServers,
  llm-agents,
  ...
}: let
  wrapWithSecrets = import ../wrap-with-secrets.nix {
    inherit pkgs lib;
  };

  llmAgentsPkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  claudeWrapped = wrapWithSecrets {
    pkg = llmAgentsPkgs.claude-code;
    binary = "claude";
    vars = {
      CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
    };
  };

  ccstatusline = pkgs.stdenv.mkDerivation {
    pname = "ccstatusline";
    version = "2.2.19";

    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/ccstatusline/-/ccstatusline-2.2.19.tgz";
      hash = "sha512-Z0AHBr1kMLYTJE5wYHp7GR4mOer6TGfa+ze0jj96vOVs9zwx1DMG4zqxFYY84lT03w4WM+notHs6JanrOZ0LFw==";
    };

    nativeBuildInputs = [pkgs.makeWrapper];
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 dist/ccstatusline.js $out/lib/ccstatusline.js
      makeWrapper ${pkgs.nodejs}/bin/node $out/bin/ccstatusline \
        --add-flags "$out/lib/ccstatusline.js"
      runHook postInstall
    '';
  };
  ccstatuslineSettings = {
    version = 3;
    colorLevel = 3;
    flexMode = "full-minus-40";
    compactThreshold = 60;
    inheritSeparatorColors = false;
    globalBold = false;
    gitCacheTtlSeconds = 5;
    minimalistMode = false;
    lines = [
      [
        {
          id = "1";
          type = "model";
          color = "cyan";
        }
        {
          id = "2";
          type = "separator";
        }
        {
          id = "10";
          type = "context-bar";
        }
        {
          id = "4";
          type = "separator";
        }
        {
          id = "5";
          type = "git-branch";
          color = "magenta";
        }
        {
          id = "6";
          type = "separator";
        }
        {
          id = "7";
          type = "git-changes";
          color = "yellow";
        }
      ]
      [
        {
          id = "11";
          type = "session-usage";
          metadata = {display = "progress";};
        }
        {
          id = "18";
          type = "custom-text";
          customText = " ";
        }
        {
          id = "16";
          type = "reset-timer";
        }
        {
          id = "12";
          type = "separator";
        }
        {
          id = "13";
          type = "weekly-usage";
          metadata = {display = "progress";};
        }
        {
          id = "19";
          type = "custom-text";
          customText = " ";
        }
        {
          id = "17";
          type = "weekly-reset-timer";
        }
        {
          id = "14";
          type = "separator";
        }
        {
          id = "15";
          type = "vim-mode";
        }
      ]
      []
    ];
    powerline = {
      enabled = false;
      separators = [""];
      separatorInvertBackground = [false];
      startCaps = [];
      endCaps = [];
      autoAlign = false;
      continueThemeAcrossLines = false;
    };
  };
in {
  home.file = import ../skills {
    inherit pkgs;
    basePath = "${config.home.homeDirectory}/.claude/skills";
  };

  xdg.configFile."ccstatusline/settings.json".text = builtins.toJSON ccstatuslineSettings;

  programs.claude-code = {
    enable = true;
    package = claudeWrapped;
    enableMcpIntegration = true;
    context = ''
      ${aiAgentsSystemInstruction}
    '';
    lspServers =
      lib.mapAttrs (_: s: {
        command = builtins.head s.command;
        args = builtins.tail s.command;
        extensionToLanguage = s.extensionToLanguage;
      })
      aiAgentsLspServers;

    settings = {
      statusLine = {
        type = "command";
        command = "${ccstatusline}/bin/ccstatusline";
        refreshInterval = 10;
      };
      permissions = {
        additionalDirectories = ["/nix/store"];
        allow = [
          "Read(//nix/store)"
          "Read(//nix/store/**)"
          "LS(//nix/store)"
          "LS(//nix/store/**)"
          "Glob(//nix/store/**)"
          "Grep(//nix/store/**)"
        ];
        deny = [
          "Edit(//nix/store/**)"
          "Write(//nix/store/**)"
          "MultiEdit(//nix/store/**)"
        ];
      };
      sandbox.filesystem.denyWrite = ["/nix/store"];
    };
  };
}
