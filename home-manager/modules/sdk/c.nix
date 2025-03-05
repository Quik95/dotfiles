{pkgs, ...}: {
  home.packages = with pkgs; [
      meson
      ninja
      clang
      clang-tools
  ];
}
