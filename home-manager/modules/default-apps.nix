{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  browser = ["com.google.Chrome.desktop"];

  # Desktop environment specific apps
  fileManager =
    if config.myHomeManager.desktopEnvironment.gnome.enable
    then ["org.gnome.Nautilus.desktop"]
    else if config.myHomeManager.desktopEnvironment.kde.enable
    then ["org.kde.dolphin.desktop"]
    else ["org.gnome.Nautilus.desktop"];

  imageViewer =
    if config.myHomeManager.desktopEnvironment.gnome.enable
    then ["org.gnome.Loupe.desktop"]
    else if config.myHomeManager.desktopEnvironment.kde.enable
    then ["org.kde.gwenview.desktop"]
    else ["org.gnome.Loupe.desktop"];

  mediaPlayer = ["mpv.desktop"];
  textEditor = ["dev.zed.Zed.desktop"];

  browserMimes = [
    "text/html"
    "x-scheme-handler/http"
    "x-scheme-handler/https"
    "x-scheme-handler/about"
    "x-scheme-handler/unknown"
  ];

  textMimes = [
    "text/plain"
    "text/x-c"
    "text/x-c++"
    "text/x-python"
    "application/x-shellscript"
    "text/markdown"
    "text/x-rust"
  ];

  imageMimes = [
    "image/avif"
    "image/gif"
    "image/jpeg"
    "image/jpg"
    "image/pjpeg"
    "image/png"
    "image/tiff"
    "image/webp"
    "image/x-bmp"
    "image/x-gray"
    "image/x-icb"
    "image/x-ico"
    "image/x-png"
  ];

  videoMimes = [
    "video/mkv"
    "video/mp4"
    "vide/webm"
  ];

  mkAssociations = mimes: app:
    builtins.listToAttrs (
      map (mime: {
        name = mime;
        value = app;
      })
      mimes
    );
in {
  config = mkIf config.myHomeManager.system.defaultApps.enable {
    xdg.mimeApps = {
    enable = true;
    defaultApplications =
      (mkAssociations browserMimes browser)
      // (mkAssociations textMimes textEditor)
      // (mkAssociations imageMimes imageViewer)
      // (mkAssociations videoMimes mediaPlayer)
      // {
        "web-browser" = browser;
        "x-scheme-handler/jetbrains" = ["jetbrains-toolbox.desktop"];
        "x-scheme-handler/fleet" = ["jetbrains-toolbox.desktop"];
        "application/pdf" =
          if config.myHomeManager.desktopEnvironment.gnome.enable
          then ["org.gnome.Papers.desktop"]
          else if config.myHomeManager.desktopEnvironment.kde.enable
          then ["org.kde.okular.desktop"]
          else ["org.gnome.Papers.desktop"];
        "inode/directory" = fileManager;
      };
    };
  };
}
