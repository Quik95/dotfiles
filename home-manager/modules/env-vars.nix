{config, ...}: {
  home.sessionVariables = {
    BROWSER = "com.google.Chrome";
    VISUAL = "zeditor";
    EDITOR = "nvim";
    PAGER = "bat";
    TERMINAL = "ghostty";
    NH_FLAKE = "${config.home.homeDirectory}/Documents/dotfiles";

    NIXOS_OZONE_WL = 1;
    NIXPKGS_ALLOW_UNFREE = 1;
  };
}
