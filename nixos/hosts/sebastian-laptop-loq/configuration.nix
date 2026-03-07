{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  networking.hostName = "sebastian-laptop-loq";

  # Clone MAC address from HP laptop for network allow-list compatibility
  networking.networkmanager.ethernet.macAddress = "c8:5a:cf:df:08:f8";
}
