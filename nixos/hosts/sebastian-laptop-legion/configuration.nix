{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./bluetooth.nix
    ./joystick-overrides.nix
    ./swap.nix
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

  # mt7925e (WiFi) jest w mainline od 6.7; regresja inicjalizacji BT MT7925 (wmt func ctrl -22) naprawiona upstream w 7.0.10 — stockowy kernel wystarcza. Patrz docs/wifi-mt7925-investigation.md.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "sebastian-laptop-legion";
  networking.networkmanager.ethernet.macAddress = "38:a7:46:3b:16:ed";

  nixfiles.i2c.enable = true;
  nixfiles.power.lenovo-conservation = {
    enable = true;
    mode = 1;
  };

  programs.steam.package = lib.mkDefault (
    pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
      };
    }
  );

  boot.kernelParams = [
    "amd_pstate=active"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    SuspendState = "mem";
  };
}
