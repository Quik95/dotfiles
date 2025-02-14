{
  programs.git = {
    enable = true;
    userName = "Sebastian Bartoszewicz";
    userEmail = "quikstyletv@gmail.com";

    difftastic.enable = true;

    aliases = {
      df = "difftool";
      d = "diff";
      s = "status";
      a = "add";
      c = "commit";
    };

    signing.format = "openpgp";

    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
      push.autoSetupRemote = true;

      merge.ff = true;

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
