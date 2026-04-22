{
  config,
  lib,
  hostname,
  ...
}: let
  isLegion = hostname == "sebastian-laptop-legion";
in {
  services.flatpak = {
    enable = true;

    packages =
      [
        "com.github.flxzt.rnote"
        "com.github.marhkb.Pods"
        "com.github.rafostar.Clapper"
        "com.github.tchx84.Flatseal"
        "com.google.Chrome"
        "com.spotify.Client"
        "dev.vencord.Vesktop"
        "garden.jamie.Morphosis"
        "org.gnome.Fractal"
        "org.gnome.gitlab.somas.Apostrophe"
        "org.jdownloader.JDownloader"
        "org.libreoffice.LibreOffice"
        "org.nickvision.money"
        "page.tesk.Refine"
      ]
      ++ lib.optionals (!isLegion) [
        "be.alexandervanhee.gradia"
        "com.mattjakeman.ExtensionManager"
        "org.gnome.Papers"
      ];
    uninstallUnmanaged = true;

    overrides = {
      "org.jdownloader.JDownloader".Context = {
        filesystems = [
          "${config.home.homeDirectory}/Videos:rw"
        ];
      };

      "org.libreoffice.LibreOffice".Context = {
        filesystems = [
          "/tmp:rw"
        ];
      };
    };

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
