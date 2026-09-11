{
  config,
  lib,
  ...
}: let
  isGnome = (import ../../../shared/desktop.nix).desktop == "gnome";
  nautilusBookmarks = [
    {
      path = "${config.home.homeDirectory}/Documents";
      name = "Documents";
    }
    {
      path = "${config.home.homeDirectory}/Downloads";
      name = "Downloads";
    }
    {
      path = "${config.home.homeDirectory}/Music";
      name = "Music";
    }
    {
      path = "${config.home.homeDirectory}/Pictures";
      name = "Pictures";
    }
    {
      path = "${config.home.homeDirectory}/Videos";
      name = "Videos";
    }
    {
      path = "/tmp";
      name = "Temp Dir";
    }
  ];
  formatBookmark = bookmark: "file://${builtins.replaceStrings [" "] ["%20"] bookmark.path} ${bookmark.name}";
  bookmarksFileContents = lib.concatStringsSep "\n" (
    lib.map formatBookmark nautilusBookmarks
  );
in
  lib.mkIf isGnome {
    xdg.configFile."gtk-3.0/bookmarks" = {
      force = true;
      text = bookmarksFileContents;
    };
  }
