{
  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "dev.vencord.Vesktop"
    "com.microsoft.Edge"
    "io.github.celluloid_player.Celluloid"
  ];

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly";
  };
}
