{
  pkgs,
  inputs,
  ...
}: let
  buildIde = inputs.nix-jetbrains-plugins.lib.buildIdeWithPlugins pkgs;
  standardPlugins = [
    "IdeaVIM"
    "nix-idea"
  ];
  # ides = ["rust-rover" "rider"];
  ides = [];
in {
  home.packages = map (name: buildIde name standardPlugins) ides;

  home.file.".config/ideavim/ideavimrc".source = ./.ideavimrc;
}
