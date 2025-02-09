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
      #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      git
      clang
      llvmPackages.bintools

      # misc
      fastfetch
      btop
      gnome-tweaks
      wget
      compsize
      bat
      wl-clipboard
      ripgrep
      fd
      sqlite
      litecli

      # python
      uv

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
