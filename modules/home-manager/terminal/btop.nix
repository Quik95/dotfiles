{
  programs.btop = {
    enable = true;
    settings = {
      theme = "Tokyo Storm";
      theme_background = true;
      true_color = true;
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      round_corners = true;
      graph_symbol = "braille";
      show_boxes = "cpu mem net proc";
      update_ms = 1500;
      proc_sorting = "cpu lazy";
    };
  };
}
