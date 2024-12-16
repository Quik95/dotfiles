{unstable, ...}: {
  home.packages = with unstable.jetbrains; [
    (plugins.addPlugins rust-rover [
      "github-copilot"
      "ideavim"
    ])
  ];

  home.file.".ideavimrc".source = ./.ideavimrc;
}
