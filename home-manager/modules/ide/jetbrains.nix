{unstable, ...}: {
  home.packages = with unstable; [
    jetbrains-toolbox
  ];
  home.file.".ideavimrc".source = ./.ideavimrc;
}
