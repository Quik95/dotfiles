{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    eslint
  ];

  programs.zed-editor = {
    enable = true;
    extensions = [
      "angular"
      "catppuccin"
      "csharp"
      "html"
      "nix"
      "typst"
      "zig"
    ];
    userSettings = {
      vim_mode = true;
      vim = {
        use_system_clipboard = "never";
        use_smartcase_find = true;
        toggle_relative_line_numbers = false;
        highlight_on_yank_duration = 200;
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
        CSharp = {
          language_servers = ["roslyn"];
        };
        JavaScript = {
          formatter = "prettier";
        };
      };
      lsp = {
        nixd = {
          binary.path = "${pkgs.nixd}/bin/nixd";
          settings = {
            nixd = {
              formatting = {
                command = ["${pkgs.alejandra}/bin/alejandra" "--"];
              };
            };
          };
        };
        json-language-server.binary = {
          path = "${pkgs.vscode-json-languageserver}/bin/vscode-json-language-server";
          arguments = ["--stdio"];
        };
        roslyn.binary = {
          path = "${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer";
          arguments = [
            "--stdio"
            "--logLevel"
            "Information"
            "--extensionLogDirectory"
            "${config.xdg.stateHome}/lsp/roslyn"
          ];
        };
        rust-analyzer.binary.path = "${pkgs.rust-analyzer}/bin/rust-analyzer";
        tinymist.binary = {
          path = "${pkgs.tinymist}/bin/tinymist";
          arguments = ["lsp"];
        };
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
      relative_line_numbers = "enabled";
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
        enable_feedback = false;
        single_file_review = false;
        default_model = {
          provider = "copilot_chat";
          model = "gemini-3-flash-preview";
        };
        inline_assistant_model = {
          provider = "copilot_chat";
          model = "gpt-5-mini";
        };
      };
      context_servers = {
        eslint-mcp = {
          command = "${pkgs.eslint}/bin/eslint";
          args = ["--mcp"];
        };
        angular-mcp = {
          command = "nix-shell";
          args = ["-p" "nodejs" "--command" "npx -y @angular/cli mcp"];
        };
      };
      edit_predictions = {
        mode = "eager";
      };
      inlay_hints = {
        enabled = true;
      };
    };

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          "ctrl-\\" = "assistant::InlineAssist";
          "ctrl-u" = ["workspace::SendKeystrokes" "1 5 k z z"];
          "ctrl-d" = ["workspace::SendKeystrokes" "1 5 j z z"];
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
          "space q o" = "pane::CloseOtherItems";
          "= =" = "editor::Format";
          "- -" = "editor::OrganizeImports";
          "g e" = "editor::GoToDiagnostic";
          "g E" = "editor::GoToPreviousDiagnostic";
          "space f u" = "editor::FindAllReferences";
          "space s u" = "editor::FindAllReferences";
          "space s s" = "editor::Hover";
          "space f s" = "outline::Toggle";
          "g i" = "editor::GoToImplementation";
          "g d" = "editor::GoToDeclaration";
          "g t" = "editor::GoToTypeDefinition";
          "g b" = "pane::GoBack";
          "g n" = "pane::GoForward";
          "e d" = "editor::Hover";
          "space r e" = "editor::Rename";
          "space r o" = "editor::ToggleCodeActions";
          "enter enter" = "editor::ToggleCodeActions";
          "shift-l" = "vim::NextSubwordStart";
          "shift-h" = "vim::PreviousSubwordStart";
          "ctrl-f" = "file_finder::Toggle";
          "ctrl-a" = "command_palette::Toggle";
          "shift shift" = "command_palette::Toggle";
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
