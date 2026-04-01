{lib, pkgs, ...}: {
  programs.lazyvim = {
    enable = true;

    extras = {
      editor = {
        fzf.enable = true;
        neo-tree.enable = true;
      };
      lang.nix.enable = true;
    };

    extraPackages = with pkgs; [
      alejandra
      nixd
      statix
    ];

    treesitterParsers = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
      angular
      bibtex
      c_sharp
      cpp
      css
      csv
      dockerfile
      fish
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      http
      json5
      kotlin
      latex
      make
      meson
      rust
      scss
      sql
    ];

    configFiles = ./config;

    plugins.nix = ''
      return {
        {
          "stevearc/conform.nvim",
          optional = true,
          opts = function(_, opts)
            opts.formatters = opts.formatters or {}
            opts.formatters.alejandra = vim.tbl_extend("force", opts.formatters.alejandra or {}, {
              command = "${lib.getExe pkgs.alejandra}",
            })
            opts.formatters_by_ft = opts.formatters_by_ft or {}
            opts.formatters_by_ft.nix = { "alejandra" }
          end,
        },
      }
    '';
  };
}
