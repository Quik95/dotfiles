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
      vim = {
        use_system_clipboard = "never";
      };
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
      autosave = "on_focus_change";
      format_on_save = "off";
      vertical_scroll_margin = 10;
      relative_line_numbers = true;
      base_keymap = "JetBrains";
      load_direnv = "shell_hook";
      command_aliases = {
        "W" = "w";
        "Wq" = "wq";
      };
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
      assistant = {
        default_model = {
          provider = "copilot_chat";
          model = "claude-3-7-sonnet";
        };
        version = "2";
      };
      edit_predictions = {
        mode = "subtle";
      };
      features = {
        inline_completion_provider = "zed";
      };
      inlay_hints = {
        enabled = true;
      };
    };

    userKeymaps = [
      {
        context = "Workspace || EmptyPane || SharedScreen";
        bindings = {
          "ctrl-f" = "file_finder::Toggle";
          "shift shift" = "command_palette::Toggle";
        };
      }
      {
        context = "Editor";
        bindings = {
          "ctrl-\\" = "assistant::InlineAssist";
        };
      }
      {
        context = "vim_mode == normal || vim_mode == visual";
        bindings = {
          "s" = ["vim::PushOperator" {"Sneak" = {};}];
          "S" = ["vim::PushOperator" {"SneakBackward" = {};}];
        };
      }
      {
        context = "VimControl && !menu";
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
          "ctrl-d" = "editor::HalfPageDown";
          "ctrl-u" = "editor::HalfPageUp";
        };
      }
    ];
  };
}
