{
  pkgs,
  config,
  ...
}: {
  home.sessionVariables = {
    OPENCODE_DISABLE_CLAUDE_CODE = 1;
  };

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
      keybinds = {
        model_list = "alt+p";
      };
      plugin = ["opencode-gemini-auth@latest"];
    };
  };
}
