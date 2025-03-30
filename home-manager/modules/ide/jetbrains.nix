{pkgs, ...}: let
  standardPlugins = ["github-copilot" "ideavim" "nixidea" "which-key"];
in {
  home.packages = with pkgs; [
    
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
