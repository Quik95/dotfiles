{
  pkgs,
  config,
  ...
}: {
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Sebastian Bartoszewicz";
        email = "quikstyletv@gmail.com";
      };

      aliases = {
        df = "difftool";
        d = "diff";
        s = "status";
        a = "add";
        c = "commit";
      };

      branch.sort = "-committerdate";
      column.ui = "auto";
      core = {
        editor = "${pkgs.neovim}/bin/nvim";
        autocrlf = "input";
      };
      help.autocorrect = true;
      init.defaultBranch = "master";
      merge.ff = true;
      pager.difftool = true;
      pull.ff = "only";
      tag.sort = "version:refname";

      diff = {
        colorMoved = "zebra";
        algorithm = "histogram";
        mnemonicPrefix = true;
        renames = true;
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

    signing = {
      signByDefault = true;
      format = "openpgp";
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

  programs.lazygit = {
    enable = true;
    settings = {
      git.overrideGpg = true;
      useExternalDiffGitConfig = true;
    };
  };

  programs.difftastic = {
    enable = true;
    git = {
      enable = true;
      diffToolMode = true;
    };
  };
}
