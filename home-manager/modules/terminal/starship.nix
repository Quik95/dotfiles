{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      format = ''$all'';

      direnv = {
        disabled = false;
      };

      git_status = {
        format = "$all_status ";
        ahead = ''↑''${count} '';
        behind = ''↓''${count} '';
        untracked = ''?''${count} '';
        staged = ''[●''${count}](green) '';
        modified = ''[✚''${count}](fg:208) '';
      };
    };
  };
}
