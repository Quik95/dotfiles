{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  networking.hostName = "sebastian-laptop-hp";
  dotfiles.eduroam.interfaceName = "wlo1";
  boot.kernelParams = ["amd_pstate=active"];
}
