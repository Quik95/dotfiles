{pkgs, ...}: let
  standardPlugins = ["github-copilot" "ideavim" "nixidea" "which-key"];
in {
  home.packages = with pkgs; [
    (jetbrains.plugins.addPlugins jetbrains.clion standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.pycharm-professional standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.webstorm standardPlugins)
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
