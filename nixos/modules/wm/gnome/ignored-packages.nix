{pkgs, ...}: {
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    cheese
    gnome-music
    gnome-terminal
    gnome-console
    gnome-contacts
    gnome-maps
    gnome-system-monitor
    gnome-extension-manager
    gnome-weather
    yelp
    epiphany
    geary
    totem
    tali
    iagno
    hitori
    atomix
  ];
}
