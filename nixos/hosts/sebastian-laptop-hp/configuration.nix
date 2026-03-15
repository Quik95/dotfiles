{...}: {
  imports = [
    ./hardware-configuration.nix
    ../../common.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "sebastian-laptop-hp";
  dotfiles.eduroam.interfaceName = "wlo1";
  dotfiles.i2c.enable = true;
  boot.kernelParams = ["amd_pstate=active"];
}
