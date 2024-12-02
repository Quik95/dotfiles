{unstable, ...}: {
  home.packages = with unstable.jetbrains; [
    pycharm-professional
  ];
}
