{
  pkgs,
  lib,
  nix-flatpak,
  lazyvim,
  sops-nix,
  stylix,
  plasma-manager,
  hostname,
  ...
}: {
  imports = [
    lazyvim.homeManagerModules.default
    nix-flatpak.homeManagerModules.nix-flatpak
    sops-nix.homeManagerModules.sops
    stylix.homeModules.stylix
    plasma-manager.homeModules.plasma-manager
  ];

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";

  home = {
    username = "sebastian";
    homeDirectory = "/home/sebastian";
    stateVersion = "24.11";
    preferXdgDirectories = true;
  };

  home.packages = with pkgs;
    [
      fortune
      ffmpeg-full
      resources
      tokei
      maestral
      fselect
      just
      mask
      mprocs
      kondo
      appimage-run

      lm_sensors
      smartmontools

      devenv
      sops
    ]
    ++ lib.optionals (hostname != "sebastian-laptop-legion") [
      # required for the gnome-system-monitor extension to work
      gnome-system-monitor
    ];
}
