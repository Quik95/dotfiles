{
  config,
  pkgs,
  ...
}: let
  browser = ["com.google.Chrome.desktop"];
  fileManager = ["org.gnome.Nautilus.desktop"];
  imageViewer = ["org.gnome.Loupe.desktop"];
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
        "application/pdf" = ["org.gnome.Evince.desktop"];
        "inode/directory" = fileManager;
      };
  };
}
