{pkgs, ...}: let
  rtkBin = "${pkgs.rtk}/bin/rtk";

  rtkSource = pkgs.fetchFromGitHub {
    owner = "rtk-ai";
    repo = "rtk";
    rev = "e53ec1cf180d801f33121855dce37b393ede258c";
    hash = "sha256-hEGrA+IuL1wJtEAFqEd5GRlbQnxXrZMxy99a9uefDXE=";
  };
in {
  _module.args.rtkSource = rtkSource;

  home.packages = [pkgs.rtk];

  xdg.configFile = {
    "claude-code/RTK.md".source = "${rtkSource}/hooks/claude/rtk-awareness.md";
  };

  programs.claude-code = {
    context = "@RTK.md";
    settings.hooks.PreToolUse = [
      {
        matcher = "Bash";
        hooks = [
          {
            type = "command";
            command = "${rtkBin} hook claude";
          }
        ];
      }
    ];
  };
}
