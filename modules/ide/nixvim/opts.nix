{
  programs.nixvim.globals = {
    mapleader = " ";
    maplocalleader = " ";
    have_nerd_font = true;
  };

  programs.nixvim.opts = {
    number = true;
    relativenumber = true;
    mouse = "a";
    showmode = false;
    breakindent = true;
    undofile = true;

    ignorecase = true;
    smartcase = true;

    signcolumn = "yes";

    updatetime = 250;
    timeoutlen = 300;

    splitright = true;
    splitbelow = true;

    list = true;
    listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";

    inccommand = "split";
    cursorline = true;
    scrolloff = 10;
  };
}
