{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sebastian-laptop-hp";

  # Clone MAC address from LOQ laptop for network allow-list compatibility
  networking.networkmanager.ethernet.macAddress = "38:a7:46:3b:16:ed";
  dotfiles.eduroam.interfaceName = "wlo1";
  dotfiles.i2c.enable = true;
  boot.kernelParams = ["amd_pstate=active"];
}
