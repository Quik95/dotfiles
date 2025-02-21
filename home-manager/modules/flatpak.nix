{
  services.flatpak = {
    enable = true;

    packages = [
      "com.github.flxzt.rnote"
      "com.github.marhkb.Pods"
      "com.github.tchx84.Flatseal"
      "com.google.Chrome"
      "com.mattjakeman.ExtensionManager"
      "com.spotify.Client"
      "dev.vencord.Vesktop"
      "garden.jamie.Morphosis"
      "it.mijorus.smile"
    ];
    uninstallUnmanaged = true;

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
