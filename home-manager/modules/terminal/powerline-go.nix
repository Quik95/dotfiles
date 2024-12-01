{
  programs.powerline-go = {
    enable = true;
    newline = false;
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
