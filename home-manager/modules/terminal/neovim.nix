{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    globals = {
      leader = " ";
      have_nerd_font = true;
      loaded_ruby_provider = 0; # Ruby
      loaded_perl_provider = 0; # Perl
      loaded_python_provider = 0; # Python 2
    };
    colorschemes.catppuccin.enable = true;

    plugins = {
      lualine.enable = true;
      oil.enable = true;
      luasnip.enable = true;
      treesitter.enable = true;
    };

    plugins.lsp = {
      enable = true;
      servers = {
        lua_ls.enable = true;
        nixd.enable = true;
      };
    };

    plugins.cmp = {
      enable = true;
      autoEnableSources = true;
      settings = {
        sources = [
          {name = "nvim_lsp";}
          {name = "cmp_luasnip";}
          {name = "path";}
          {name = "buffer";}
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = ''
            cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
                elseif luasnip.expandable() then
                    luasnip.expand()
                elseif luasnip.expendable_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif check_backspace() then
                    fallback()
                else
                    fallback()
                end
            end, { 'i', 's' })
          '';
        };
      };
    };

    opts = {
      updatetime = 100;

      number = true;
      relativenumber = true;

      incsearch = true;
      ignorecase = true;
      smartcase = true;

      scrolloff = 8;
      cursorline = true;

      fileencoding = "utf-8";
      termguicolors = true;

      spell = true;
      wrap = false;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      autoindent = true;
    };

    extraConfigLua = ''
      require("lspconfig").nixd.setup({
        cmd = { "nixd" },
        settings = {
            nixd = {
                nixpkgs = {
                    expr = "import <nixpkgs> { }",
                },
                formatting = {
                    command = { "alejandra" },
                },
            },
        },
      })
    '';
  };
}
