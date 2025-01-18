{
  programs.git = {
    enable = true;
    userName = "Sebastian Bartoszewicz";
    userEmail = "quikstyletv@gmail.com";

    difftastic.enable = true;

    extraConfig = {
      init.defaultBranch = "master";
      diff.colorMoved = "zebra";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };

    ignores = [
      "*~"
      ".DS_Store"
    ];
  };

  programs.lazygit.enable = true;
}
