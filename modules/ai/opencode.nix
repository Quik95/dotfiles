{
  pkgs,
  lib,
  config,
  aiAgentsSystemInstruction,
  aiAgentsGitContextCommand,
  aiAgentsLspServers,
  llm-agents,
  ...
}: let
  wrapWithSecrets = import ./wrap-with-secrets.nix {
    inherit pkgs lib;
  };

  llmAgentsPkgs = llm-agents.packages.${pkgs.stdenv.hostPlatform.system};

  opencodeWrapped = wrapWithSecrets {
    pkg = llmAgentsPkgs.opencode;
    binary = "opencode";
    vars = {
      CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
    };
  };

  opencodeProcessWrapped = pkgs.symlinkJoin {
    name = "${opencodeWrapped.pname or opencodeWrapped.name}-process-env";
    paths = [opencodeWrapped];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/opencode --set OPENCODE_EXPERIMENTAL_DISABLE_COPY_ON_SELECT "true" --set OPENCODE_DISABLE_LSP_DOWNLOAD "true"
    '';
  };
in {
  home.file = import ./skills {
    inherit pkgs;
    basePath = "${config.xdg.configHome}/opencode/skills";
  };

  xdg.configFile."opencode/opencode-quota/quota-toast.json".text = builtins.toJSON {
    enableToast = false;
  };

  programs.opencode = {
    enable = true;
    package = opencodeProcessWrapped;
    enableMcpIntegration = true;
    commands = {
      git-context = aiAgentsGitContextCommand;
    };
    context = ''
      ${aiAgentsSystemInstruction}
    '';
    settings = {
      lsp =
        lib.mapAttrs (_: s: {
          command = [(lib.concatStringsSep " " s.command)];
          extensions = lib.attrNames s.extensionToLanguage;
        })
        aiAgentsLspServers;
      formatter = {
        nixfmt = {
          command = ["${pkgs.alejandra}" "--quiet" "$FILE"];
        };
      };
      permission = {
        external_directory = {
          "/nix/store/**" = "allow";
        };
      };
    };
    tui = {
      keybinds = {
        model_list = "alt+p";
      };
      plugin = ["@slkiser/opencode-quota"];
    };
  };
}
