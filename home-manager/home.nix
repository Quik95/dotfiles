{
  pkgs,
  nix-flatpak,
  nixvim,
  ...
}: {
  imports = [
    nixvim.homeManagerModules.nixvim
    nix-flatpak.homeManagerModules.nix-flatpak

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
    maestral

    # required for the gnome-system-monitor extension to work
    gnome-system-monitor
    lm_sensors
    smartmontools

    devenv
  ];
}
