{pkgs, ...}: {
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

  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

  environment.systemPackages = with pkgs; [
    git
    clang
    llvmPackages.bintools

    # terminal essentials
    neovim
    fish
    ripgrep
    fd
    btop
    bat

    # filesystems
    ntfs3g
    jmtpfs

    # misc
    fastfetch
    gnome-tweaks
    wget
    compsize
    wl-clipboard
    sqlite
    litecli
    ouch
    mtr
    file
    iw
    wirelesstools
    gparted
    usbutils

    # fonts
    powerline-fonts

    # nix stuff
    nixd
    nil
    alejandra
    nix-output-monitor
    nvd
    nurl
  ];
}
