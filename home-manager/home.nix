{
  pkgs,
  nix-flatpak,
  nixvim,
  ...
}: {
  imports = [
    nix-flatpak.homeManagerModules.nix-flatpak
    nixvim.homeManagerModules.nixvim

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
    rustup

    # required for the gnome-system-monitor extension to work
    gnome-system-monitor
    lm_sensors
    smartmontools

    devenv
  ];
}
