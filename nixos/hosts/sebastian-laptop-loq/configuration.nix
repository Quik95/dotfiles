{lib, ...}: {
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./gpu-specialisations.nix
  ];

  nixfiles.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    extraEntries = ''
      /CachyOS
        protocol: efi_chainload
        image_path: guid(693a1c82-49ed-471e-9148-b8713c216f5f):/EFI/limine/limine_x64.efi
    '';
  };

  networking.hostName = "sebastian-laptop-loq";
  nixfiles.eduroam.interfaceName = "wlp9s0";
  nixfiles.i2c.enable = true;
  nixfiles.passwordless-sudo.enable = false;
  nixfiles.power.lenovo-conservation = {
    enable = true;
    mode = 1;
  };

  # --- PAMIĘĆ I SWAP ---
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  # Override hardware-configuration's 4 GB swap with 18 GB for hibernation
  swapDevices = lib.mkForce [
    {
      device = "/swap/swapfile";
      size = 18432;
    }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 125;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # --- HIBERNACJA I ZARZĄDZANIE ENERGIĄ ---
  boot.resumeDevice = "/dev/disk/by-uuid/17c79fd8-ce47-40f6-8953-c926267eb013";
  boot.kernelParams = ["resume_offset=47286090"];

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "120m";
    SuspendState = "mem";
  };
}
