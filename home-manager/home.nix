{
  pkgs,
  lib,
  inputs,
  ...
}: let
  env = import ../shared/env.nix;
  desktop = (import ../shared/desktop.nix).desktop;
  isGnome = desktop == "gnome";
  isPlasma = desktop == "plasma";
in {
  imports = [
    inputs.lazyvim.homeManagerModules.default
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    inputs.sops-nix.homeManagerModules.sops
    inputs.stylix.homeModules.stylix
    inputs.plasma-manager.homeModules.plasma-manager
    inputs.neko-rs.homeModules.nekors
  ];

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";

  home = {
    inherit (env) username homeDirectory;
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

      sops
    ]
    ++ lib.optionals isGnome [
      # required for the gnome-system-monitor extension to work
      gnome-system-monitor
    ];

  # The display is HiDPI, so the 32x32 sprites need doubling.
  # Plasma only: nekors draws through zwlr_layer_shell_v1, which mutter does not
  # implement, and it is fed cursor positions by a KWin script
  # (Plugins.nekorsEnabled in modules/wm/plasma/behavior.nix).
  services.nekors = {
    enable = isPlasma;
    extraArgs = ["--scale" "2"];
  };
}
