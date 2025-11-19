{
  pkgs,
  lib,
  ...
}: let
  extensions = with pkgs.gnomeExtensions; [
    {
      pkg = activate-window-by-title;
      enabled = false;
    }
    {
      pkg = appindicator;
      enabled = true;
    }
    {
      pkg = bluetooth-quick-connect;
      enabled = true;
      dconfPath = "bluetooth-quick-connect";
      settings = {
        keep-menu-on-toggle = true;
        show-battery-value-on = true;
      };
    }
    {
      pkg = blur-my-shell;
      enabled = true;
    }
    {
      pkg = caffeine;
      enabled = true;
      dconfPath = "caffeine";
      settings = {
        show-notifications = false;
      };
    }
    {
      pkg = clipboard-indicator;
      enabled = true;
    }
    {
      pkg = fullscreen-hot-corner;
      enabled = true;
    }
    {
      pkg = just-perfection;
      enabled = true;
      dconfPath = "just-perfection";
      settings = {
        activities-button = false;
        search = false;
        workspace-wrap-around = false;
        window-demands-attention-focus = true;
        background-menu = false;
        window-preview-caption = false;
        workspace-switcher-should-show = true;
        workspace-switcher-size = 15;
      };
    }
    {
      pkg = launch-new-instance;
      enabled = true;
    }
    {
      pkg = random-wallpaper;
      enabled = false;
    }
    {
      pkg = removable-drive-menu;
      enabled = true;
    }
    {
      pkg = smile-complementary-extension;
      enabled = true;
    }
    {
      pkg = system-monitor;
      enabled = true;
    }
  ];

  mkDconfSettings = exts:
    lib.foldl' (
      acc: ext:
        if ext ? "settings" && ext ? "dconfPath"
        then acc // {"org/gnome/shell/extensions/${ext.dconfPath}" = ext.settings;}
        else acc
    ) {}
    exts;
in {
  dconf.settings =
    mkDconfSettings extensions
    // {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = [];
        enabled-extensions =
          lib.map (ext: ext.pkg.extensionUuid)
          (lib.filter (ext: ext.enabled) extensions);
      };
    };

  home.packages = lib.map (ext: ext.pkg) extensions;
}
