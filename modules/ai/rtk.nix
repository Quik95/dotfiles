{
  pkgs,
  inputs,
  ...
}: let
  rtkBin = "${pkgs.rtk}/bin/rtk";

  rtkSource = inputs.rtk-source;
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
