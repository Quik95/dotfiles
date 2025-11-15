{config, ...}: {
  home.sessionVariables = {
    BROWSER = "firefox";
    VISUAL = "zeditor";
    EDITOR = "nvim";
    PAGER = "bat";
    TERMINAL = "ghostty";
    NH_FLAKE = "${config.home.homeDirectory}/Documents/dotfiles";

    NIXOS_OZONE_WL = 1;
    NIXPKGS_ALLOW_UNFREE = 1;
  };
}
