{
  pkgs,
  nix-flatpak,
  nixvim,
  sops-nix,
  stylix,
  ...
}: {
  imports = [
    nixvim.homeManagerModules.nixvim
    nix-flatpak.homeManagerModules.nix-flatpak
    sops-nix.homeManagerModules.sops
    stylix.homeModules.stylix

    ./modules/default.nix
  ];

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";

  home = {
    username = "sebastian";
    homeDirectory = "/home/sebastian";
    stateVersion = "24.11";
  };

  home.packages = with pkgs; [
    fortune
    ffmpeg-full
    resources
    tokei
    maestral
    vdhcoapp
    fselect
    just
    mask
    mprocs
    kondo
    appimage-run
    litecli
    zed-editor

    # required for the gnome-system-monitor extension to work
    gnome-system-monitor
    lm_sensors
    smartmontools

    devenv
    sops
  ];
}
