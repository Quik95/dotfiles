{pkgs, ...}: {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    agents = {
      bash-expert = builtins.readFile ./subagents/bash.md;
      dotnet-core-expert = builtins.readFile ./subagents/dotnet.md;
      powershell-expert = builtins.readFile ./subagents/powershell.md;
    };
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
