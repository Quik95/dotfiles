let
  env = import ../../../shared/env.nix;
in {
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 5d --keep 3";
    flake = "${env.homeDirectory}/Documents/dotfiles";
  };
}
