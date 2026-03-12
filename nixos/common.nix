{pkgs, ...}: let
  env = import ../shared/env.nix;
in {
  imports = [
    ./modules/default.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # DNS configuration
  networking.nameservers = ["1.1.1.1" "8.8.8.8"];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Firmware updates via LVFS
  services.fwupd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.sebastian = {
    isNormalUser = true;
    description = "Sebastian Bartoszewicz";
    extraGroups = ["networkmanager" "wheel" "i2c"];
  };

  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    use-xdg-base-directories = true;
  };

  nix.extraOptions = ''
    trusted-users = root sebastian
    extra-substituters = https://devenv.cachix.org https://cache.numtide.com
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw= niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=
  '';

  services.flatpak.enable = true;
  environment.variables = {
    EDITOR = env.editor;
    VISUAL = env.visual;
    TERMINAL = env.terminal;
    PAGER = env.pager;
  };

  # https://github.com/NixOS/nixpkgs/issues/149812
  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';

  # MTP stuff
  services.gvfs.enable = true;

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
