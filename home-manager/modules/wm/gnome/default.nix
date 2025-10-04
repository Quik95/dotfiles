{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./dconf.nix
    ./extensions.nix
    ./nautilus.nix
  ];

  config = mkIf config.myHomeManager.desktopEnvironment.gnome.enable {
    # GNOME-specific packages
    home.packages = with pkgs; [
      gnome-system-monitor
      lm_sensors
      smartmontools
    ];
  };
}
