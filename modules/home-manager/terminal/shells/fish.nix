{
  programs.fish = {
    enable = true;
    shellAbbrs = {
      mkdir = "mkdir -p";
      rm = "rm -I";
      cp = "cp -riv";
      du = "du -sh";
      copy = "wl-copy <";
      drsync = "rsync --archive --verbose --progress --partial --info=progress2 --human-readable --no-inc-search";
      fP = "fish --private";
      icat = "kitty +kitten icat";
      ytt = "yt-dlp --format \'bestvideo[height<=?1080]+bestaudio/best\' -P /tmp/";

      plog = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      gs = "git status";
      ga = "git add .";
      gc = "git commit -m";
    };
    shellAliases = {
      ls = "eza -ahm -F --git --icons --no-permissions --no-user";
    };
    interactiveShellInit = ''
      function fish_greeting
        fortune
      end
    '';
  };
}
