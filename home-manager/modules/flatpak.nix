{
  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "dev.vencord.Vesktop"
    "com.microsoft.Edge"
    "com.mattjakeman.ExtensionManager"
    "com.github.flxzt.rnote"
    "com.github.marhkb.Pods"
    "com.spotify.Client"
    "garden.jamie.Morphosis"
    "it.mijorus.smile"
  ];

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly";
  };
}
