{
  pkgs,
  lib,
  ...
}: let
  servers = {
    bash = {
      package = pkgs.bash-language-server;
      command = [(lib.getExe pkgs.bash-language-server) "start"];
      extensionToLanguage = {
        ".sh" = "shellscript";
        ".bash" = "shellscript";
        ".zsh" = "shellscript";
        ".ksh" = "shellscript";
      };
    };
    dotnet = {
      package = pkgs.omnisharp-roslyn;
      command = [(lib.getExe pkgs.omnisharp-roslyn)];
      extensionToLanguage = {
        ".cs" = "csharp";
        ".csx" = "csharp";
      };
    };
    html = {
      package = pkgs.superhtml;
      command = [(lib.getExe pkgs.superhtml) "lsp"];
      extensionToLanguage = {
        ".html" = "html";
        ".shtml" = "html";
        ".htm" = "html";
      };
    };
    json = {
      package = pkgs.vscode-json-languageserver;
      command = [(lib.getExe pkgs.vscode-json-languageserver) "--stdio"];
      extensionToLanguage = {
        ".json" = "json";
        ".jsonc" = "jsonc";
      };
    };
    nixd = {
      package = pkgs.nixd;
      command = [(lib.getExe pkgs.nixd)];
      extensionToLanguage = {
        ".nix" = "nix";
      };
    };
    python = {
      package = pkgs.pyrefly;
      command = [(lib.getExe pkgs.pyrefly) "lsp"];
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };
    rust = {
      package = pkgs.rust-analyzer;
      command = [(lib.getExe pkgs.rust-analyzer)];
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };
    typst = {
      package = pkgs.tinymist;
      command = [(lib.getExe pkgs.tinymist) "lsp"];
      extensionToLanguage = {
        ".typ" = "typst";
        ".typc" = "typst";
      };
    };
    typescript = {
      package = pkgs.typescript-language-server;
      command = [(lib.getExe pkgs.typescript-language-server) "--stdio"];
      extensionToLanguage = {
        ".ts" = "typescript";
        ".tsx" = "typescriptreact";
        ".js" = "javascript";
        ".jsx" = "javascriptreact";
        ".mjs" = "javascript";
        ".cjs" = "javascript";
        ".mts" = "typescript";
        ".cts" = "typescript";
      };
    };
  };
in {
  _module.args.aiAgentsLspServers = servers;

  home.packages = lib.mapAttrsToList (_: s: s.package) servers;
}
