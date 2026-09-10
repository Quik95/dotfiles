{config, ...}: {
  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${config.stylix.inputs.tinted-schemes}/base24/purple-rain.yaml";
    fonts.sizes = {
      applications = 11;
      desktop = 9;
      popups = 9;
      terminal = 11;
    };
    targets = {
      bat.enable = true;
      btop.enable = true;
      fish.enable = true;
      firefox = {
        enable = true;
        profileNames = ["default"];
      };
      ghostty.enable = true;
      helix.enable = true;
      kde.enable = false;
      kitty.enable = true;
      lazygit.enable = true;
      mpv.enable = true;
      neovim.enable = true;
    };
  };
}
