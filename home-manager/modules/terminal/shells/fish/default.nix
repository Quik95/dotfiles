{pkgs, ...}: {
  home.packages = [
    pkgs.grc
  ];

  programs.fish = {
    enable = true;
    generateCompletions = true;

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
    };

    shellAliases = {
      ls = "eza -ahm -F --git --icons --no-permissions --no-user";
      g = "git";
      lg = "lazygit";
      sudo = "run0";
      nix-shell = "nix-shell --run fish";
      wlcopy = "wl-copy";
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
      {
        name = "puffer";
        src = puffer.src;
      }
    ];
    functions = {
      fish_greeting = "fortune";
      mkcd = "mkdir -p $argv[1] && cd $argv[1]";
      detach = {
        description = "Run command in background and forget about it completely";
        body = builtins.readFile ./detach.fish;
      };
    };
    interactiveShellInit = ''
      fish_vi_key_bindings

      # Preserve useful default keybindings in insert mode
      bind -M insert \cp up-or-search        # Ctrl+p: previous history
      bind -M insert \cn down-or-search      # Ctrl+n: next history
      bind -M insert \cf forward-char        # Ctrl+f: move forward
      bind -M insert \cb backward-char       # Ctrl+b: move backward
      bind -M insert \ca beginning-of-line   # Ctrl+a: move to beginning
      bind -M insert \ce end-of-line         # Ctrl+e: move to end
      bind -M insert \ck kill-line           # Ctrl+k: delete to end of line
      bind -M insert \cw backward-kill-word  # Ctrl+w: delete word backwards

      # Completion function for detach - suggest commands from PATH
      complete -c detach -a '(__fish_complete_command)'
    '';
  };
}
