{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./gpu-specialisations.nix
    ./bluetooth.nix
  ];

  nixfiles.enable = true;

  fileSystems."/".options = ["compress=zstd"];
  fileSystems."/home".options = ["compress=zstd"];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    extraEntries = ''
      /CachyOS
        protocol: efi_chainload
        image_path: guid(50dc3c4d-786c-4282-8bc1-3c0bc12ebae7):/EFI/limine/limine_x64.efi

      /Windows
        protocol: efi_chainload
        image_path: guid(37f7fac0-c32a-424d-b7b9-7b9b9581b575):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  networking.hostName = "sebastian-laptop-legion";
  networking.networkmanager.ethernet.macAddress = "38:a7:46:3b:16:ed";
  nixfiles.eduroam.interfaceName = "wlp4s0";

  nixfiles.i2c.enable = true;
  nixfiles.passwordless-sudo.enable = false;
  nixfiles.power.lenovo-conservation = {
    enable = true;
    mode = 1;
  };

  boot.kernelParams = ["amd_pstate=active"];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  swapDevices = lib.mkForce [];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 125;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    SuspendState = "mem";
  };
}
