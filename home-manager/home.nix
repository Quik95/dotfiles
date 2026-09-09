{
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}: {
  imports = [
    inputs.lazyvim.homeManagerModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.sops-nix.homeManagerModules.sops
    inputs.stylix.homeModules.stylix
    inputs.plasma-manager.homeModules.plasma-manager
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
      git-absorb
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
