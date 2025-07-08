{pkgs, ...}: {
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
      auto_update = false;
      languages = {
        Nix = {
          language_servers = ["nixd"];
        };
      };
      lsp = {
        nixd = {
          binary = {
            path = "${pkgs.nixd}/bin/nixd";
          };
          settings.formatting.command = ["${pkgs.alejandra}/bin/alejandra" "--"];
        };
        pylsp = {
          binary = {
            path = "${pkgs.python313Packages.python-lsp-server}/bin/pylsp";
          };
        };
        package-version-server = {
          binary = {
            path = "${pkgs.package-version-server}/bin/package-version-server";
          };
        };
        zls = {
          binary.path = "${pkgs.zls}/bin/zls";
        };
      };
      autosave = "on_focus_change";
      format_on_save = "off";
      vertical_scroll_margin = 10;
      relative_line_numbers = true;
      default_keymap = "JetBrains";
      load_direnv = "shell_hook";
      command_aliases = {
        "W" = "w";
        "Wq" = "wq";
      };
      indent_guides = {
        enabled = true;
        coloring = "indent_aware";
      };
      agent = {
        version = "2";
        enabled = true;
        default_model = {
          provider = "copilot_chat";
          model = "claude-sonnet-4";
        };
      };
      edit_predictions = {
        mode = "subtle";
      };
      ai = {
        completion_provider = "zed";
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
          "s" = ["vim::PushSneak" {}];
          "S" = ["vim::PushSneakBackward" {}];
        };
      }
      {
        context = "VimControl && !menu";
        bindings = {
          "tab" = "pane::ActivateNextItem";
          "shift-tab" = "pane::ActivatePreviousItem";
          "space b d" = "pane::CloseActiveItem";
          "space q a" = "pane::CloseAllItems";
          "space q o" = "pane::CloseInactiveItems";
          "= =" = "editor::Format";
          "g e" = "editor::GoToDiagnostic";
          "g E" = "editor::GoToPreviousDiagnostic";
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
