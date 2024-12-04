{unstable, ...}: {
  home.packages = with unstable.jetbrains; [
    rust-rover
  ];
}
