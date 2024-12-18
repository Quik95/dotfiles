{pkgs, ...}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    extensions = with pkgs.vscode-extensions; [
      vscodevim.vim
      jnoortheen.nix-ide
      github.copilot
      k--kato.intellij-idea-keybindings
      catppuccin.catppuccin-vsc
      usernamehw.errorlens
    ];
    userSettings = {
      "keyboard.dispatch" = "keyCode";
      "editor.fontSize" = 16;
      "files.autoSave" = "onFocusChange";
      "editor.minimap.enabled" = false;

      "workbench.colorTheme" = "Catppuccin Mocha";
      "catppuccin.accentColor" = "pink";
      "editor.semanticHighlighting.enabled" = true;
      "terminal.integrated.minimumContrastRatio" = 1;
      "window.titleBarStyle" = "custom";

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nixd}/bin/nixd";
      "nix.serverSettings.nixd.formatting.command" = ["${pkgs.alejandra}/bin/alejandra"];

      "vscode-neovim.neovimExecutablePaths.linux" = "${pkgs.neovim}/bin/nvim";
      "extensions.experimental.affinity" = {
        "vscodevim.vim" = 1;
      };

      "vim.incsearch" = true;
      "vim.hlsearch" = true;
      "vim.autoindent" = true;
      "vim.smartcase" = true;
      "vim.showcmd" = true;
      "vim.showmode" = true;
      "vim.useSystemClipboard" = false;
      "vim.highlightedyank.enable" = true;
      "vim.useControlKeys" = true;

      "vim.leader" = " ";
      "vim.normalModeKeyBindingsNonRecursive" = [
        {
          before = ["<tab>"];
          commands = ["workbench.action.nextEditor"];
        }
        {
          before = ["<S-tab>"];
          commands = ["workbench.action.previousEditor"];
        }

        {
          before = ["<leader>" "b" "d"];
          commands = ["workbench.action.closeActiveEditor"];
        }
        {
          before = ["<leader>" "q" "a"];
          commands = ["workbench.action.closeAllEditors"];
        }
        {
          before = ["q" "o"];
          commands = ["workbench.action.closeOtherEditors"];
        }

        {
          before = ["=" "="];
          commands = ["editor.action.formatDocument"];
        }

        {
          before = ["<laeder>" "g" "e"];
          commands = ["workbench.action.problems.next"];
        }
        {
          before = ["<leader>" "g" "E"];
          commands = ["workbench.action.problems.previous"];
        }

        {
          before = ["<C-a>"];
          commands = ["workbench.action.gotoAction"];
        }

        {
          before = ["<enter>" "<enter>"];
          commands = ["editor.action.quickFix"];
        }
      ];
    };
  };
}
