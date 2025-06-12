{
  services.flatpak = {
    enable = true;

    packages = [
      "be.alexandervanhee.gradia"
      "com.github.flxzt.rnote"
      "com.github.marhkb.Pods"
      "com.github.tchx84.Flatseal"
      "com.google.Chrome"
      "com.mattjakeman.ExtensionManager"
      "com.spotify.Client"
      "com.valvesoftware.Steam"
      "dev.vencord.Vesktop"
      "garden.jamie.Morphosis"
      "it.mijorus.smile"
      "org.gnome.Fractal"
      "page.tesk.Refine"
    ];
    uninstallUnmanaged = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
