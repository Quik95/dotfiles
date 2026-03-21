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

      alias = {
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
        tool = "difftastic";
      };
      difftool.prompt = false;
      "difftool \"difftastic\"".cmd = "difft \"$LOCAL\" \"$REMOTE\"";

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
      git = {
        overrideGpg = true;
        pagers = [
          {
            pager = "delta --paging=never";
          }
          {
            externalDiffCommand = "difft --color=always";
          }
        ];
      };
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
    };
  };

  programs.difftastic.enable = true;
}
