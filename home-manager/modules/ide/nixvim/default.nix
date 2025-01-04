{
  imports = [
    ./opts.nix
    ./keymaps.nix
    ./misc.nix

    ./plugins/default.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    colorschemes.catppuccin.enable = true;
    plugins.lualine.enable = true;

    withRuby = false;
    withPython3 = false;
    withPerl = false;
    withNodeJs = false;
  };
}
