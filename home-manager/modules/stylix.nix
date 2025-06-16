{pkgs, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/digital-rain.yaml";
    targets = {
      bat.enable = true;
      btop.enable = true;
      fish.enable = true;
      ghostty.enable = true;
      helix.enable = true;
      kde.enable = true;
      kitty.enable = true;
      lazygit.enable = true;
      mpv.enable  = true;
    };
  };
}
