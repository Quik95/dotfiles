{lib, ...}: let
  isGnome = (import ../../../shared/desktop.nix).desktop == "gnome";
in {
  imports = [
    ./ignored-packages.nix
  ];

  config = lib.mkIf isGnome {
    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.displayManager.gdm.autoSuspend = false;
    services.desktopManager.gnome.enable = true;

    programs.dconf.enable = true;

    xdg.portal.enable = true;

    services.xserver.autoRepeatDelay = 200;
    services.xserver.autoRepeatInterval = 15;

    services.desktopManager.gnome.extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.keyboard]
      repeat-interval=15
      delay=200
      numlock-state=true
      remember-numlock-state=true
    '';
  };
}
