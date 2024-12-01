{
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish.shellAliases = {cd = "__zoxide_z";};
}
