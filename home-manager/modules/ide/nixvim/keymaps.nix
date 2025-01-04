{
  programs.nixvim.keymaps = [
    {
      key = "<Esc>";
      action = "<cmd>nohlsearch<CR>";
      mode = "n";
    }
    {
      key = "<C-h>";
      action = "<C-w><C-h>";
      mode = "n";
      options = {desc = "Move focus to the left window";};
    }
    {
      key = "<C-l>";
      action = "<C-w><C-l>";
      mode = "n";
      options = {desc = "Move focus to the right window";};
    }
    {
      key = "<C-j>";
      action = "<C-w><C-j>";
      mode = "n";
      options = {desc = "Move focus to the lower window";};
    }
    {
      key = "<C-k>";
      action = "<C-w><C-k>";
      mode = "n";
      options = {desc = "Move focus to the upper window";};
    }
  ];
}
