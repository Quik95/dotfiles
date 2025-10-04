{
  config,
  pkgs,
  ...
}: {
  # Import common profile
  imports = [./common.nix];

  # Enable GNOME desktop environment
  myHomeManager.desktopEnvironment.gnome.enable = true;
}
