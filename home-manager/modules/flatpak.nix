{
  services.flatpak = {
    enable = true;

    packages = [
      "be.alexandervanhee.gradia"
      "com.github.flxzt.rnote"
      "com.github.marhkb.Pods"
      "com.github.rafostar.Clapper"
      "com.github.tchx84.Flatseal"
      "com.google.Chrome"
      "com.mattjakeman.ExtensionManager"
      "com.spotify.Client"
      "com.valvesoftware.Steam"
      "dev.vencord.Vesktop"
      "garden.jamie.Morphosis"
      "org.gnome.Fractal"
      "org.gnome.Papers"
      "org.gnome.gitlab.somas.Apostrophe"
      "org.libreoffice.LibreOffice"
      "org.nickvision.money"
      "page.tesk.Refine"
    ];
    uninstallUnmanaged = true;

    overrides = {
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
