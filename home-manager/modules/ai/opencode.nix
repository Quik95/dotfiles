{pkgs, ...}: let
  subagentsRepo = pkgs.fetchFromGitHub {
    owner = "VoltAgent";
    repo = "awesome-claude-code-subagents";
    rev = "950a37966440f3725f00ed45ccfcdfdce7704361";
    hash = "sha256-/fs/af41/9uXrOw6++t4+bfTkmS2y22Qgxy0tu9CxrY=";
  };
in {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    agents = {
      dotnet-core-expert = let
        content = builtins.readFile "${subagentsRepo}/categories/02-language-specialists/dotnet-core-expert.md";
      in
        builtins.replaceStrings
        ["tools: Read, Write, Edit, Bash, Glob, Grep"]
        ["mode: subagent\ntools:\n  read: true\n  write: true\n  edit: true\n  bash: true\n  glob: true\n  grep: true"]
        content;
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
