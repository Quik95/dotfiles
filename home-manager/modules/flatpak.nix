{
  services.flatpak = {
    enable = true;

    packages = [
      "com.github.tchx84.Flatseal"
      "dev.vencord.Vesktop"
      "com.mattjakeman.ExtensionManager"
      "com.github.flxzt.rnote"
      "com.github.marhkb.Pods"
      "com.spotify.Client"
      "garden.jamie.Morphosis"
      "it.mijorus.smile"
      "com.google.Chrome"
    ];
    uninstallUnmanaged = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
