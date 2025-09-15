{pkgs, ...}: {
  home.packages = with pkgs; [eslint];

  programs.zed-editor = {
    enable = true;
    extensions = [
      "angular"
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
        JavaScript = {
          formatter = "prettier";
        };
      };
      lsp = {
        nixd = {
          binary.path = "${pkgs.nixd}/bin/nixd";
          settings.formatting.command = ["${pkgs.alejandra}/bin/alejandra" "--"];
        };
        json-language-server.binary = {
          path = "${pkgs.vscode-json-languageserver}/bin/vscode-json-language-server";
          arguments = ["--stdio"];
        };
        rust-analyzer.binary.path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        pylsp.binary.path = "${pkgs.python313Packages.python-lsp-server}/bin/pylsp";
        package-version-server.binary.path = "${pkgs.package-version-server}/bin/package-version-server";
        vtsls.binary = {
          path = "${pkgs.vtsls}/bin/vtsls";
          arguments = ["--stdio"];
        };
        zls.binary.path = "${pkgs.zls}/bin/zls";
      };
      completions = {
        lsp_insert_mode = "replace";
      };
      features = {
        edit_prediction_provider = "zed";
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
      agent = {
        enabled = true;
        use_modifier_to_send = true;
        default_model = {
          provider = "copilot_chat";
          model = "claude-sonnet-4";
        };
      };
      agent-servers = {
        "Gemini CLI" = {
            command = "${pkgs.gemini-cli}/bin/gemini";
            args = ["--experimental-acp"];
        };
      };
      context_servers = {
        eslint-mcp = {
          source = "custom";
          command = "${pkgs.eslint}/bin/eslint";
          args = ["--mcp"];
        };
        angular-mcp = {
          source = "custom";
          command = "nix-shell";
          args = ["-p" "nodejs" "--command" "npx -y @angular/cli mcp"];
        };
      };
      edit_predictions = {
        mode = "subtle";
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
        context = "Editor && vim_mode == visual && !menu";
        bindings = {
          "v" = "editor::SelectLargerSyntaxNode";
          "V" = "editor::SelectSmallerSyntaxNode";
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
        context = "VimControl && !menu && vim_mode != operator";
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
          "shift-l" = "vim::NextSubwordStart";
          "shift-h" = "vim::PreviousSubwordStart";
        };
      }
      {
        context = "vim_operator == a || vim_operator == i || vim_operator == cs";
        bindings = {
          "q" = "vim::MiniQuotes";
          "b" = "vim::MiniBrackets";
        };
      }
    ];
  };
}
