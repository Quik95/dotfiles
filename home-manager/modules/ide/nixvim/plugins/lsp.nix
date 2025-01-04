{
  programs.nixvim = {
    plugins = {
      cmp-nvim-lsp.enable = true;
      fidget.enable = true;
    };

    autoGroups = {
      "kickstart-lsp-attach" = {
        clear = true;
      };
    };

    plugins.lsp = {
      enable = true;
      servers = {
        lua_ls = {
          enable = true;
          settings = {
            completion.callSnippet = "Replace";
          };
        };
        nixd = {
          enable = false;
        };
        nil_ls = {
          enable = true;
        };
        ruff = {
          enable = true;
        };
        rust_analyzer = {
          enable = true;
          installCargo = false;
          installRustc = false;
        };
      };
      keymaps = {
        extra = [
          {mode = "n"; key = "gd"; action.__raw = "require('telescope.builtin').lsp_definitions"; options = {desc = "LSP: Goto Definition";};}  
          {mode = "n"; key = "gi"; action.__raw = "require('telescope.builtin').lsp_implementations"; options = {desc = "LSP: Goto Implementation";};}  
          {mode = "n"; key = "su"; action.__raw = "require('telescope.builtin').lsp_references"; options = {desc = "LSP: Show usages";};}  
          {mode = "n"; key = "K"; action.__raw = "require('telescope.builtin').lsp_type_definitions"; options = {desc = "LSP: Type Definitions";};}  
          {mode = "n"; key = "ds"; action.__raw = "require('telescope.builtin').lsp_document_symbols"; options = {desc = "LSP: Document Symbols";};}  
          {mode = "n"; key = "ws"; action.__raw = "require('telescope.builtin').lsp_dynamic_workspace_symbols"; options = {desc = "LSP: Workspace Symbols";};}  
        ];
        lspBuf = {
          "<leader>rn" = {action = "rename"; desc = "LSP: Rename";};
          "<CR><CR>" = {action = "code_action"; desc = "LSP: Code Action";};
          "<leader>gD" = {action = "declaration"; desc = "LSP: Goto Declaration";};
        };
      };
    };
  };
}
