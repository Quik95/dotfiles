{
  imports = [
    ./gnome/default.nix
  ];

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  programs.dconf.enable = true;
  services.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.desktop.peripherals.keyboard]
    repeat-interval=15
    delay=200
    numlock-state=true
    remember-numlock-state=true
  '';
}
