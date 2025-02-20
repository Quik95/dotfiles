{pkgs, ...}: {
  # Install firefox.
  programs.firefox.enable = true;

  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  programs.fish.enable = true;
  environment.shells = [pkgs.bashInteractive pkgs.fish];
  users.defaultUserShell = pkgs.fish;
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };

  environment.systemPackages = with pkgs; [
    git
    clang
    llvmPackages.bintools

    # terminal essencials
    neovim
    fish
    ripgrep
    fd
    btop
    bat

    # misc
    fastfetch
    gnome-tweaks
    wget
    compsize
    wl-clipboard
    sqlite
    litecli
    ouch
    ntfs3g
    mtr

    # fonts
    powerline-fonts

    # nix stuff
    nixd
    nil
    alejandra
    nix-output-monitor
    nvd
  ];
}
