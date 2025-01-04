{
  pkgs,
  unstable,
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

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home = {
    username = "sebastian";
    homeDirectory = "/home/sebastian";
    stateVersion = "24.11";
  };

  home.packages =
    (with pkgs; [
      fortune
      ffmpeg-full
      resources
      tokei
      rustup
    ])
    ++ (with unstable; [
      ghostty
    ]);
}
