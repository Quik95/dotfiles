{...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  nixfiles.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sebastian-laptop-hp";

  # Clone MAC address from LOQ laptop for network allow-list compatibility
  networking.networkmanager.ethernet.macAddress = "38:a7:46:3b:16:ed";
  nixfiles.eduroam.interfaceName = "wlo1";
  nixfiles.i2c.enable = true;
  boot.kernelParams = ["amd_pstate=active"];
}
