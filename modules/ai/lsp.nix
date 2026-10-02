{
  pkgs,
  lib,
  config,
  ...
}: let
  servers = {
    bashls = {
      package = pkgs.bash-language-server;
      command = [(lib.getExe pkgs.bash-language-server) "start"];
      zedName = null;
      extensionToLanguage = {
        ".sh" = "shellscript";
        ".bash" = "shellscript";
        ".zsh" = "shellscript";
        ".ksh" = "shellscript";
      };
    };
    roslyn = {
      package = pkgs.roslyn-ls;
      command = [
        "${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer"
        "--stdio"
        "--logLevel"
        "Information"
        "--extensionLogDirectory"
        "${config.xdg.stateHome}/lsp/roslyn"
      ];
      extensionToLanguage = {
        ".cs" = "csharp";
        ".csx" = "csharp";
      };
    };
    superhtml = {
      package = pkgs.superhtml;
      command = [(lib.getExe pkgs.superhtml) "lsp"];
      zedName = null;
      extensionToLanguage = {
        ".html" = "html";
        ".shtml" = "html";
        ".htm" = "html";
      };
    };
    vscode-json-language-server = {
      package = pkgs.vscode-json-languageserver;
      command = [(lib.getExe pkgs.vscode-json-languageserver) "--stdio"];
      zedName = "json-language-server";
      extensionToLanguage = {
        ".json" = "json";
        ".jsonc" = "jsonc";
      };
    };
    nixd = {
      package = pkgs.nixd;
      command = [(lib.getExe pkgs.nixd)];
      settings.nixd.formatting.command = ["${pkgs.alejandra}/bin/alejandra" "--"];
      extensionToLanguage = {
        ".nix" = "nix";
      };
    };
    basedpyright = {
      package = pkgs.basedpyright;
      command = ["${pkgs.basedpyright}/bin/basedpyright-langserver" "--stdio"];
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };
    ruff = {
      package = pkgs.ruff;
      command = [(lib.getExe pkgs.ruff) "server"];
      isLinter = true;
      extensionToLanguage = {
        ".py" = "python";
        ".pyi" = "python";
      };
    };
    rust-analyzer = {
      package = pkgs.rust-analyzer;
      command = [(lib.getExe pkgs.rust-analyzer)];
      extensionToLanguage = {
        ".rs" = "rust";
      };
    };
    tinymist = {
      package = pkgs.tinymist;
      command = [(lib.getExe pkgs.tinymist) "lsp"];
      extensionToLanguage = {
        ".typ" = "typst";
        ".typc" = "typst";
      };
    };
    vtsls = {
      package = pkgs.vtsls;
      command = [(lib.getExe pkgs.vtsls) "--stdio"];
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
    zls = {
      package = pkgs.zls;
      command = [(lib.getExe pkgs.zls)];
      extensionToLanguage = {
        ".zig" = "zig";
        ".zon" = "zig";
      };
    };
    terraform-ls = {
      package = pkgs.terraform-ls;
      command = [(lib.getExe pkgs.terraform-ls) "serve"];
      extensionToLanguage = {
        ".tf" = "terraform";
        ".tfvars" = "terraform-vars";
      };
    };
    # Zed's dependency-version helper has no standalone language mapping.
    package-version-server = {
      package = pkgs.package-version-server;
      command = [(lib.getExe pkgs.package-version-server)];
      extensionToLanguage = {};
    };
  };
in {
  _module.args.aiAgentsLspServers = servers;

  # zls needs a zig toolchain on PATH for build-on-save and std resolution.
  home.packages = lib.mapAttrsToList (_: s: s.package) servers ++ [pkgs.zig];
}
