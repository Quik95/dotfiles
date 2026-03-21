{
  programs.nixvim = {
    autoGroups = {
      kickstart-highlight-yank = {
        clear = true;
      };
    };

    autoCmd = [
      {
        event = ["TextYankPost"];
        desc = "Highlight when yanking text";
        group = "kickstart-highlight-yank";
        callback.__raw = ''
          function()
            vim.highlight.on_yank({higroup = "Visual", timeout = 150})
          end
        '';
      }
    ];
  };
}
