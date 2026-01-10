{
  pkgs,
  config,
  nix-jetbrains-plugins,
  ...
}: let
  buildIde = nix-jetbrains-plugins.lib.buildIdeWithPlugins pkgs;
  standardPlugins = ["IdeaVIM" "nix-idea"];
  ides = ["rust-rover" "rider"];
in {
  home.packages = builtins.map (name: buildIde name standardPlugins) ides;

  home.file."${config.xdg.configHome}/ideavim/ideavimrc".source = ./.ideavimrc;
}
