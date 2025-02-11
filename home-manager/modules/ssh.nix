{
  programs.ssh = {
    enable = true;
    addKeysToAgent = "ask";
  };

  services.ssh-agent = {
    enable = true;
  };
}
