{
  pkgs,
  config,
  ...
}: let
  jetbrains = (import
    (pkgs.fetchFromGitHub {
        owner = "NixOS";
        repo = "nixpkgs";
        rev = "94def634a20494ee057c76998843c015909d6311";
        hash = "sha256-K2ViRJfdVGE8tpJejs8Qpvvejks1+A4GQej/lBk5y7I=";
      }
    )
    {
      inherit (config.nixpkgs) config;
      localSystem = {
        system = "x86_64-linux";
      };
    }
  ).jetbrains;
  # standardPlugins = ["github-copilot" "ideavim" "nixidea" "which-key"];
  standardPlugins = ["ideavim" "nixidea"];
in {
  home.packages = [
    (jetbrains.plugins.addPlugins jetbrains.clion standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.rust-rover standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.datagrip standardPlugins)
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
