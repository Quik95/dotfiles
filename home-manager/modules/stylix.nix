{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-macchiato.yaml";
    targets = {
      bat.enable = true;
      btop.enable = true;
      fish.enable = true;
      ghostty.enable = true;
      gnome.enable = true;
      gtk.enable = true;
      gtk.flatpakSupport.enable = true;
      helix.enable = true;
      kitty.enable = true;
      lazygit.enable = true;
      mpv.enable  = true;
    };
  };
}
