{
  config,
  pkgs,
  ...
}: {
  # Import common profile
  imports = [./common.nix];

  # Enable KDE desktop environment
  myHomeManager.desktopEnvironment.kde.enable = true;
}
