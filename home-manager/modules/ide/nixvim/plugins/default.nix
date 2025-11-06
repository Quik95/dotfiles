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
    lualine.enable = true;
    web-devicons.enable = true;
    todo-comments.enable = true;
    auto-save.enable = true;
  };
}
