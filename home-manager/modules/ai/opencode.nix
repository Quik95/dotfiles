{
  pkgs,
  config,
  ...
}: let
  skillsDirectory = "${config.xdg.configHome}/opencode/skills";
in {
  home.sessionVariables = {
    OPENCODE_DISABLE_CLAUDE_CODE = 1;
  };

  home.file."${skillsDirectory}/bash-expert/SKILL.md".source = ./skills/bash.md;
  home.file."${skillsDirectory}/dotnet-core-expert/SKILL.md".source = ./skills/dotnet.md;
  home.file."${skillsDirectory}/powershell-expert/SKILL.md".source = ./skills/powershell.md;

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
      };
      formatter = {
        nixfmt = {
          command = ["${pkgs.alejandra}" "--quiet" "$FILE"];
        };
      };
      plugin = ["opencode-gemini-auth@latest"];
    };
  };
}
