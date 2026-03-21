{pkgs, ...}: {
  programs.nixvim.plugins.treesitter = {
    enable = true;
    settings = {
      highlight = {
        enable = true;
        additional_vim_regex_highlighting = true;
      };

      indent.enable = true;
    };

    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      angular
      bash
      bibtex
      c
      c_sharp
      cpp
      css
      csv
      diff
      dockerfile
      fish
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      html
      http
      javascript
      json
      json5
      kotlin
      latex
      lua
      luadoc
      make
      markdown
      markdown_inline
      meson
      nix
      python
      regex
      rust
      scss
      sql
      toml
      typescript
      vim
      vimdoc
    ];
  };
}
