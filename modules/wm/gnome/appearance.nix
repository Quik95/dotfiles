{
  pkgs,
  lib,
  ...
}: let
  isGnome = (import ../../../shared/desktop.nix).desktop == "gnome";
in
  lib.mkIf isGnome {
    # Plasma leaves "breeze" / "breeze_cursors" behind in the dconf database, and
    # those themes are not installed once plasma6 is gone: GTK then falls back to
    # blank squares for both the pointer and the titlebar icons. Name the themes
    # that GNOME actually ships so the switch is self-contained either way.
    dconf.settings."org/gnome/desktop/interface" = {
      icon-theme = "Adwaita";
      cursor-theme = "Adwaita";
      cursor-size = 24;
    };

    # kde-gtk-config also wrote "icon" into the decoration layout, so GTK draws an
    # app-icon button at the left of the headerbar; with "breeze" gone it renders
    # as the broken-image placeholder. GNOME never shows that button, so drop it.
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = "appmenu:minimize,maximize,close";

    # The stale ~/.config/gtk-{3,4}.0/settings.ini Plasma wrote still names
    # "breeze" / "breeze_cursors" and outranks gsettings for GTK apps, so own
    # those files here instead of leaving them behind.
    gtk = {
      enable = true;
      iconTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita";
        package = pkgs.adwaita-icon-theme;
        size = 24;
      };
      gtk3.extraConfig.gtk-decoration-layout = "appmenu:minimize,maximize,close";
      gtk4.extraConfig.gtk-decoration-layout = "appmenu:minimize,maximize,close";
    };

    # Same cursor for XWayland and Qt clients, which do not read gsettings.
    home.pointerCursor = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      x11.enable = true;
    };
  }
