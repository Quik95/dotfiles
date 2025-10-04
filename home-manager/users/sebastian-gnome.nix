{
  pkgs,
  nix-flatpak,
  nixvim,
  sops-nix,
  stylix,
  ...
}: {
  imports = [
    nixvim.homeModules.nixvim
    nix-flatpak.homeManagerModules.nix-flatpak
    sops-nix.homeManagerModules.sops
    stylix.homeModules.stylix

    ../modules/default.nix
    ../profiles/gnome.nix
  ];

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";

  home = {
    username = "sebastian";
    homeDirectory = "/home/sebastian";
    stateVersion = "24.11";
  };
}
