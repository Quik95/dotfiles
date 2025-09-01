{
  pkgs,
  config,
  ...
}: let
  jetbrains = pkgs.jetbrains;
  # standardPlugins = ["github-copilot" "ideavim" "nixidea" "which-key"];
  standardPlugins = ["ideavim" "nixidea"];
in {
  home.packages = [
    (jetbrains.plugins.addPlugins jetbrains.webstorm standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.rust-rover standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.datagrip standardPlugins)
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
