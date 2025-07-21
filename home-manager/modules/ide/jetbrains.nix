{
  pkgs,
  config,
  ...
}: let
  jetbrains = (import
    (builtins.fetchTarball {
      # Date: 20250713
      # https://github.com/NixOS/nixpkgs/issues/425328
      url = "https://github.com/NixOS/nixpkgs/tarball/9807714d6944a957c2e036f84b0ff8caf9930bc0";
      sha256 = "sha256:1g9qc3n5zx16h129dqs5ixfrsff0dsws9lixfja94r208fq9219g";
    })
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
    (jetbrains.plugins.addPlugins jetbrains.idea-ultimate standardPlugins)
    (jetbrains.plugins.addPlugins jetbrains.datagrip standardPlugins)
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
