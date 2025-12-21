{
  imports = [
    ./opts.nix
    ./keymaps.nix
    ./misc.nix

    ./plugins/default.nix
  ];

  programs.nixvim = let
    env = import ../../../../shared/env.nix;
  in {
    enable = true;
    defaultEditor = env.editor == "nvim";
    plugins.lualine.enable = true;

    withRuby = false;
    withPython3 = false;
    withPerl = false;
    withNodeJs = false;

    performance.byteCompileLua = {
      enable = true;
      nvimRuntime = true;
      plugins = true;
    };
  };
}
