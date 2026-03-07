{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  networking.hostName = "sebastian-laptop-hp";
  boot.kernelParams = ["amd_pstate=active"];
}
