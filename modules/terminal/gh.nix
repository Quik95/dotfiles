{...}: let
  env = import ../../shared/env.nix;
in {
  programs.gh = {
    enable = true;

    gitCredentialHelper.enable = false;

    settings = {
      git_protocol = "ssh";
      editor = env.editor;
      prompt = "enabled";
    };
  };
}
