{
  programs.nixvim.plugins.neo-tree = {
    enable = true;
    filesystem.window.mappings = {
      "\\" = "close_window";
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "\\";
      action = "<cmd>Neotree reveal<cr>";
      options = {
        desc = "Neotree reveal";
      };
    }
  ];
}
