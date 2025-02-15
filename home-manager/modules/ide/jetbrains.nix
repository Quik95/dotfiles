{pkgs, ...}: let
  standardPlugins = ["github-copilot" "ideavim"];
in {
  home.packages = with pkgs; [
    (jetbrains.plugins.addPlugins jetbrains.clion standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.rust-rover standardPlugins)
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
