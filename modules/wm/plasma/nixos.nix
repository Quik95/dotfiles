{
  config,
  lib,
  pkgs,
  ...
}:
lib.mkIf (config.networking.hostName == "sebastian-laptop-legion") {
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.packagekit.enable = false;
  environment.plasma6.excludePackages = [pkgs.kdePackages.discover];

  programs.dconf.enable = true;

  xdg.portal.enable = true;

  services.xserver.autoRepeatDelay = 200;
  services.xserver.autoRepeatInterval = 15;

  security.pam.services.sddm.kwallet.enable = true;
  security.pam.services.kde.kwallet.enable = true;
  security.pam.services.login.kwallet.enable = true;

  programs.ssh.startAgent = true;
  programs.ssh.enableAskPassword = true;
  programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  environment.systemPackages = [
    pkgs.kdePackages.ksshaskpass
    # KDE's native on-screen virtual keyboard (new in Plasma 6.7).
    # Selected as KWin's input method in modules/wm/plasma/behavior.nix.
    pkgs.kdePackages.plasma-keyboard
  ];
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";
}
