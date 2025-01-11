_: let
  flash = func: {__raw = ''function() require("flash").${func}() end'';};
in
{
  programs.nixvim = {
    plugins.flash.enable = true;
    keymaps = [
      {
        key = "s";
        mode = ["n" "x" "o"];
        action = flash "jump";
        options = {
          desc = "Flash";
          silent = true;
        };
      }
    ];
  };
}
