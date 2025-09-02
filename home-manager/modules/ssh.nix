{pkgs, config, ...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      addKeysToAgent = "ask";
      compression = false;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };
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
