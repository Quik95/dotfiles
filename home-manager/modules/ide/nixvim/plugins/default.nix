{
  imports = [
    ./autopairs.nix
    ./flash.nix
    ./gitsigns.nix
    ./indent-blankline.nix
    ./lsp.nix
    ./neo-tree.nix
    ./nvim-cmp.nix
    ./telescope.nix
    ./treesitter.nix
    ./which-key.nix
  ];

  programs.nixvim.plugins = {
    sleuth.enable = true;
    lualine.enable = true;
    web-devicons.enable = true;
    todo-comments.enable = true;
    luasnip.enable = true;
  };
}
