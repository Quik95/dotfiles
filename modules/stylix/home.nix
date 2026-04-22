{pkgs, ...}: let
  tt-schemes = pkgs.fetchFromGitHub {
    owner = "tinted-theming";
    repo = "schemes";
    rev = "b15ea410ff2091a064a92d0f6b8bae80a2f27798";
    hash = "sha256-pDz3SALMXwLvqvVPKj2pQn1Cr6WsPTWICaUhWfmXAYI=";
  };
in {
  stylix = {
    enable = true;
    autoEnable = false;
    base16Scheme = "${tt-schemes}/base24/purple-rain.yaml";
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
      opencode.enable = true;
    };
  };
}
