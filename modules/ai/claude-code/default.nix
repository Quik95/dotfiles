{
  pkgs,
  lib,
  config,
  aiAgentsSystemInstruction,
  aiAgentsLspServers,
  inputs,
  ...
}: let
  wrapWithSecrets = import ../wrap-with-secrets.nix {
    inherit pkgs lib;
  };
  env = import ../../../shared/env.nix;

  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  claudeWrapped = wrapWithSecrets {
    pkg = llmAgentsPkgs.claude-code;
    binary = "claude";
    vars = {
      CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
    };
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
          id = "21";
          type = "custom-text";
          customText = " (";
          color = "cyan";
        }
        {
          id = "20";
          type = "thinking-effort";
          rawValue = true;
          color = "cyan";
        }
        {
          id = "22";
          type = "custom-text";
          customText = ")";
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
  ccstatuslineSettingsFile = pkgs.writeText "ccstatusline-settings.json" (builtins.toJSON ccstatuslineSettings);
  ccstatuslineSettingsPath = "${config.xdg.configHome}/ccstatusline/settings.json";
in {
  # ccstatusline updates its settings file, so keep it outside the Nix store.
  home.activation.installCcstatuslineSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ ! -v DRY_RUN ]]; then
      install -d -m 0755 "$(dirname "${ccstatuslineSettingsPath}")"
      rm -f "${ccstatuslineSettingsPath}"
      install -m 0644 "${ccstatuslineSettingsFile}" "${ccstatuslineSettingsPath}"
    fi
  '';
  xdg.configFile."mimeapps.list".force = true; # idk, I don't care that much

  programs.claude-code = {
    enable = true;
    package = claudeWrapped;
    configDir = env.claudeConfigDir config;
    enableMcpIntegration = true;
    context = aiAgentsSystemInstruction;
    skills = import ../skills {inherit inputs;};
    lspServers =
      lib.mapAttrs (_: s: {
        command = builtins.head s.command;
        args = builtins.tail s.command;
        extensionToLanguage = s.extensionToLanguage;
      })
      aiAgentsLspServers;

    settings = {
      includeCoAuthoredBy = false;
      respondToBashCommands = false;
      model = "claude-opus-5";
      effortLevel = "low";
      modelSettings."claude-opus-5".effortLevel = "low";
      skipDangerousModePermissionPrompt = true;
      env = {
        "CLAUDE_CODE_DISABLE_1M_CONTEXT" = 1;
      };
      statusLine = {
        type = "command";
        command = "${llmAgentsPkgs.ccstatusline}/bin/ccstatusline";
        refreshInterval = 10;
      };
      permissions = {
        defaultMode = "bypassPermissions";
        additionalDirectories = ["/nix/store"];
        allow = [
          "Read(//nix/store)"
          "Read(//nix/store/**)"
          "LS(//nix/store)"
          "LS(//nix/store/**)"
          "Grep(//nix/store/**)"
        ];
        deny = [
          "Edit(//nix/store/**)"
        ];
      };
      sandbox.filesystem.denyWrite = ["/nix/store"];
    };
  };
}
