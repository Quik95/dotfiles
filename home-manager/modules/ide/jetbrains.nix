{unstable, ...}: {
  home.packages = with unstable.jetbrains; [
    rust-rover
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
