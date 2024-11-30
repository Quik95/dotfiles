{
  services.flatpak.packages = [
    "com.github.tchx84.Flatseal"
    "dev.vencord.Vesktop"
    "com.microsoft.Edge"
    "com.mattjakeman.ExtensionManager"
  ];

  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly";
  };
}
