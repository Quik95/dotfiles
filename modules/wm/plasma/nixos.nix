{
  config,
  lib,
  ...
}:
lib.mkIf (config.networking.hostName == "sebastian-laptop-legion") {
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.packagekit.enable = false;

  programs.dconf.enable = true;

  xdg.portal.enable = true;

  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 15;
}
