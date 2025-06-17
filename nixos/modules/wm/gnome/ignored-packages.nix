{pkgs, ...}: {
  environment.gnome.excludePackages = with pkgs; [
    atomix
    cheese
    epiphany
    evince
    geary
    gnome-console
    gnome-contacts
    gnome-extension-manager
    gnome-maps
    gnome-music
    gnome-system-monitor
    gnome-terminal
    gnome-tour
    gnome-weather
    hitori
    iagno
    tali
    totem
    yelp
  ];
}
