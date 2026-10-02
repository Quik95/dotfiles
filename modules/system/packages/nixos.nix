{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.fish.enable = true;
  environment.shells = [
    pkgs.bashInteractive
    pkgs.fish
  ];
  users.defaultUserShell = pkgs.fish;

  hardware.opentabletdriver = {
    enable = false;
    daemon.enable = true;
  };

  environment.systemPackages = with pkgs;
    [
      git

      # terminal essentials
      bat
      btop
      fd
      fish
      ghostty
      neovim
      powershell
      ripgrep
      shellcheck
      shfmt

      # filesystems
      ntfs3g

      # misc
      fastfetch
      wget
      compsize
      wl-clipboard
      jq
      sqlite
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
      alejandra
      nix-output-monitor
      nvd
      nurl
      hydra-check
    ]
    ++ lib.optionals config.services.desktopManager.gnome.enable [
      gnome-tweaks
    ];

  programs.nix-index-database.comma.enable = true;
}
