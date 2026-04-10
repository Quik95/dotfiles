{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./gpu-specialisations.nix
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

  networking.hostName = "sebastian-laptop-legion";
  networking.networkmanager.ethernet.macAddress = "38:a7:46:3b:16:ed";
  nixfiles.eduroam.interfaceName = "wlp4s0";

  nixfiles.i2c.enable = true;
  nixfiles.passwordless-sudo.enable = false;
  nixfiles.power.lenovo-conservation = {
    enable = true;
    mode = 1;
  };

  boot.kernelParams = [
    "amd_pstate=active"
    # Prevent ACPI EC from immediately waking the system during s2idle,
    # which happens when an external monitor is connected via NVIDIA HDMI.
    "acpi.ec_no_wakeup=1"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # Stop the GDM greeter user session before suspend. Without this, systemd-sleep
  # tries to freeze user.slice while logind simultaneously removes the greeter
  # session (user@60578 / gdm-greeter), causing a 60s deadlock timeout.
  systemd.services.pre-sleep-gdm-greeter-cleanup = {
    description = "Stop GDM greeter session before suspend";
    before = ["sleep.target"];
    wantedBy = ["sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "-${pkgs.systemd}/bin/systemctl stop user@60578.service";
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    SuspendState = "mem";
  };
}
