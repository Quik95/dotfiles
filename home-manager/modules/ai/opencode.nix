{
  pkgs,
  lib,
  config,
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

  programs.opencode = {
    enable = true;
    package = opencodeProcessWrapped;
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
      keybinds = {
        model_list = "alt+p";
      };
      plugin = ["opencode-gemini-auth@latest"];
    };
  };
}
