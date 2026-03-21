{
  programs.powerline-go = {
    enable = true;
    newline = true;
    modules = [
      "venv"
      "user"
      "host"
      "ssh"
      "cwd"
      "perms"
      "git"
      "exit"
      "root"
      "nix-shell"
    ];
    settings = {
      theme = "gruvbox";
    };
  };
}
