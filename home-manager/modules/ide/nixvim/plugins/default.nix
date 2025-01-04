{
  imports = [
    ./which-key.nix
    ./treesitter.nix
    ./gitsigns.nix
    ./telescope.nix
    ./neo-tree.nix
    ./autopairs.nix
    ./nvim-cmp.nix
    ./indent-blankline.nix
    ./lsp.nix
  ];

  programs.nixvim.plugins = {
    sleuth.enable = true;
    lualine.enable = true;
    web-devicons.enable = true;
    todo-comments.enable = true;
  };
}
