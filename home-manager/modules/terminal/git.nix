{
  programs.git = {
    enable = true;
    userName = "Sebastian Bartoszewicz";
    userEmail = "quikstyletv@gmail.com";

    difftastic.enable = true;

    aliases = {
      df = "difftool";
    };

    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;

      diff = {
        tool = "difftastic";
        colorMoved = "zebra";
      };

      difftool = {
        prompt = false;
        difftastic = {
          cmd = ''difft "$LOCAL" "$REMOTE"'';
        };
      };

      pager.diftool = true;
    };

    ignores = [
      "*~"
      ".DS_Store"
    ];
  };

  programs.lazygit.enable = true;
}
