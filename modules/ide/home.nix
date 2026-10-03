{
  imports = [
    ./devenv.nix
    ./direnv.nix
    ./helix.nix
    ./vscode.nix
    ./zed.nix

    ./lazyvim/default.nix
  ];

  home.file.".config/ideavim/ideavimrc".source = ./.ideavimrc;
}
