{
  pkgs,
  ...
}: {
  # Install firefox.
  programs.firefox.enable = true;

  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  environment.systemPackages =
    (with pkgs; [
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

      # fonts
      powerline-fonts

      # nix stuff
      nixd
      nil
      alejandra
      nix-output-monitor
      nvd
    ]);
    }
