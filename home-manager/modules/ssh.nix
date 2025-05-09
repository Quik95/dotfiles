{pkgs, ...}: {
  programs.ssh = {
    enable = true;
    addKeysToAgent = "ask";
  };

  services.ssh-agent = {
    enable = true;
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableFishIntegration = true;
    pinentry.package = pkgs.pinentry-gnome3;
  };
}
