{config, ...}: {
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

    signing = {
      signByDefault = true;
      format = "openpgp";
    };

    extraConfig = {
      branch.sort = "-comitterdate";
      column.ui = "auto";
      core.autocrlf = "input";
      help.autocorrect = true;
      init.defaultBranch = "master";
      merge.ff = true;
      pager.diftool = true;
      pull.ff = "only";
      tag.sort = "version:refname";

      diff = {
        tool = "difftastic";
        colorMoved = "zebra";
        algorithm = "histogram";
        mnemonicPrefix = true;
        renames = true;
      };

      difftool = {
        prompt = false;
        difftastic = {
          cmd = ''difft "$LOCAL" "$REMOTE"'';
        };
      };

      fetch = {
        prune = true;
        pruneTags = true;
        all = true;
      };

      push = {
        default = "simple";
        autoSetupRemote = true;
        followTags = true;
      };

      rebase = {
        autoSquash = true;
        autoStash = true;
        updateRefs = true;
      };

      rerere = {
        enable = true;
        autoupdate = true;
      };
    };

    ignores = [
      "*~"
      ".DS_Store"
    ];

    includes = [
      {
        condition = "gitdir:${config.home.homeDirectory}/Projects/Studia/Magisterka/";
        contents = {
          user = {
            name = "Sebastian Bartoszewicz";
            email = "sebastian.bartoszewicz@student.put.poznan.pl";
          };
        };
      }
    ];
  };

  programs.lazygit.enable = true;
}
