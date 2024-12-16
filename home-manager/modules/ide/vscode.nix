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
    };
  };
}
