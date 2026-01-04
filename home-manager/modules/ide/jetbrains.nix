{
  pkgs,
  config,
  nix-jetbrains-plugins,
  ...
}: let
  inherit (nix-jetbrains-plugins.lib.${pkgs.system}) buildIdeWithPlugins;
  standardPlugins = ["IdeaVIM" "nix-idea"];
in {
  home.packages = [
    (buildIdeWithPlugins pkgs.jetbrains "rust-rover" standardPlugins)
    (buildIdeWithPlugins pkgs.jetbrains "rider" standardPlugins)
  ];

  home.file."${config.xdg.configHome}/ideavim/ideavimrc".source = ./.ideavimrc;
}
