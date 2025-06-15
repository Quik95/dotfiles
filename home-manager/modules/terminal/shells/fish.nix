{pkgs, ...}: {
  home.packages = [pkgs.grc];

  programs.fish = {
    enable = true;
    shellAbbrs = {
      mkdir = "mkdir -p";
      rm = "rm -I";
      cp = "cp -riv";
      du = "du -sh";
      copy = "wl-copy <";
      drsync = "rsync --archive --verbose --progress --partial --info=progress2 --human-readable";
      fP = "fish --private";
      icat = "kitty +kitten icat";
      ytt = "yt-dlp --format \'bestvideo[height<=?1080]+bestaudio/best\' -P /tmp/";

      plog = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      gs = "git status";
      ga = "git add .";
      gc = "git commit -m";
      gd = "git diff";
      nsf = "nix-shell --run fish";
    };
    shellAliases = {
      ls = "eza -ahm -F --git --icons --no-permissions --no-user";
      g = "git";
      lg = "lazygit";
      sudo = "run0";
    };
    plugins = with pkgs.fishPlugins; [
      {
        name = "grc";
        src = grc.src;
      }
      {
        name = "autopair";
        src = autopair.src;
      }
      {
        name = "colored-man-pages";
        src = colored-man-pages.src;
      }
    ];
    interactiveShellInit = ''
      function fish_greeting
        fortune
      end
    '';
  };
}
