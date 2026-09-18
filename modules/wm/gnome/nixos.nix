{
  pkgs,
  lib,
  ...
}: let
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

    # GSConnect is the GNOME-native KDE Connect implementation. Enabling the
    # kdeconnect module with the extension as its package is what opens the
    # TCP/UDP 1714-1764 range the protocol needs; the shell extension on its own
    # installs fine but never discovers a phone.
    programs.kdeconnect = {
      enable = true;
      package = pkgs.gnomeExtensions.gsconnect;
    };

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
