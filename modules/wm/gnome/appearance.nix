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

    # Same cursor for XWayland and Qt clients, which do not read gsettings.
    home.pointerCursor = {
      enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      x11.enable = true;
    };
  }
