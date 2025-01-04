{
  programs.nixvim = {
    plugins.cmp = {
      enable = true;
      settings = {
        snippet = {
          expand = ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
        };

        completion = {
          completeopt = "menu,menuone,noinsert";
        };

        sources = [
          {name = "luasnip";}
          {name = "nvim_lsp";}
          {name = "path";}
        ];

        mapping = {
          "<C-n>" = "cmp.mapping.select_next_item()";
          "<C-p>" = "cmp.mapping.select_prev_item()";
          "<Tab>" = "cmp.mapping.select_next_item()";
          "<S-Tab>" = "cmp.mapping.select_prev_item()";
          "<CR>" = "cmp.mapping.confirm {select = true}";
          "<C-Space>" = "cmp.mapping.complete {}";

          "<C-b>" = "cmp.mapping.scroll_docs(-4)";
          "<C-f>" = "cmp.mapping.scroll_docs(4)";
          "<C-l>" = ''
             cmp.mapping(function()
               if luasnip.expand_or_locally_jumpable() then
                 luasnip.expand_or_jump()
               end
             end, { 'i', 's' })
          '';
          "<C-h>" = ''
            cmp.mapping(function()
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              end
            end, { 'i', 's' })
          '';
        };
      };
    };
  };
}
