{pkgs, ...}: {
  home.packages = with pkgs; [
    jetbrains-toolbox
  ];
  home.file.".ideavimrc".source = ./.ideavimrc;
}
