{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  config = mkIf config.myHomeManager.desktopEnvironment.gnome.enable {
    dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;

      disabled-extensions = [
      ];

      enabled-extensions = [
        # built-in
        "appindicatorsupport@rgcjonas.gmail.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "status-icons@gnome-shell-extensions.gcampax.github.com"

        # additional
        "blur-my-shell@aunetx"
        "bluetooth-quick-connect@bjarosze.gmail.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "fullscreen-hot-corner@sorrow.about.alice.pm.me"
        "just-perfection-desktop@just-perfection"
        # "randomwallpaper@iflow.space"
        "smile-extension@mijorus.it"
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "launch-new-instance@gnome-shell-extensions.gcampax.github.com"
      ];
    };

    "org/gnome/shell/extensions/bluetooth-quick-connect" = {
      keep-menu-on-toggle = true;
      show-battery-value-on = true;
    };

    "org/gnome/shell/extensions/caffeine" = {
      show-notifications = false;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      activities-button = false;
      search = false;
      workspace-wrap-around = false;
      window-demands-attention-focus = true;
      background-menu = false;
      window-preview-caption = false;
      workspace-switcher-should-show = true;
      workspace-switcher-size = 15;
    };
  };

    home.packages = with pkgs.gnomeExtensions; [
      appindicator
      blur-my-shell
      activate-window-by-title
      just-perfection
      clipboard-indicator
      # panel-corners
      bluetooth-quick-connect
      caffeine
      fullscreen-hot-corner
      random-wallpaper
      smile-complementary-extension
      system-monitor
    ];
  };
}
