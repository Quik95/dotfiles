{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  imports = [
    ./plasma.nix
  ];

  config = mkIf config.myHomeManager.desktopEnvironment.kde.enable {
    # KDE-specific packages
    home.packages = with pkgs; [
      kdePackages.dolphin
      kdePackages.gwenview
      kdePackages.okular
      kdePackages.kate
      kdePackages.spectacle
      kdePackages.ark
      kdePackages.filelight
      kdePackages.kcalc
    ];
  };
}
