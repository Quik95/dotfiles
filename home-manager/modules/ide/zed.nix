{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "html"
      "catppuccin"
      "zig"
      "nix"
    ];
    userSettings = {
      vim_mode = true;
      buffer_font_size = 14;
      theme = {
        mode = "dark";
        light = "One Light";
        dark = "Catppuccin Macchiato";
      };
      languages = {
        Nix = {
          language_servers = ["nixd"];
        };
      };
      lsp = {
        nixd.settings.formatting.command = ["alejandra" "--"];
      };
      format_on_save = "on";
      autosave = "on_focus_change";
      vertical_scroll_margin = 10;
      relative_line_numbers = true;
      base_keymap = "JetBrains";
      command_aliases = {
        "W" = "w";
        "Wq" = "wq";
      };
    };

    userKeymaps = [
      {
        context = "Workspace";
        bindings = {
          "ctrl-f" = "file_finder::Toggle";
          "shift shift" = "command_pallette::Toggle";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-\\" = "assistant::InlineAssist";
        };
      }
      {
        context = "Editor && vim_mode != insert && vim_operator == none && !VimWaiting";
        bindings = {
          "tab" = "pane::ActivateNextItem";
          "shift-tab" = "pane::ActivatePrevItem";
          "space b d" = "pane::CloseActiveItem";
          "space q a" = "pane::CloseAllItems";
          "space q o" = "pane::CloseInactiveItems";
          "= =" = "editor::Format";
          "g e" = "editor::GoToDiagnostic";
          "g E" = "editor::GoToPrevDiagnostic";
          "space f u" = "editor::FindAllReferences";
          "g i" = "editor::GoToImplementation";
          "g d" = "editor::GoToDeclaration";
          "e d" = "editor::Hover";
        };
      }
    ];
  };
}
