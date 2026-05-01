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

  programs.steam.package = lib.mkDefault (
    pkgs.steam.override {
      extraEnv = {
        MANGOHUD = true;
      };
    }
  );

  boot.kernelParams = [
    "amd_pstate=active"
    # Prevent ACPI EC from immediately waking the system during s2idle,
    # which happens when an external monitor is connected via NVIDIA HDMI.
    "acpi.ec_no_wakeup=1"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # GPP0 (0000:00:01.1) is the PCIe root port for the NVIDIA dGPU. With this
  # wakeup source enabled, any PCIe link event on that port (including normal
  # D3 transitions) immediately aborts s2idle. Disable it at boot.
  systemd.services.disable-nvidia-pcie-wakeup = {
    description = "Disable NVIDIA PCIe root port wakeup source (GPP0)";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "disable-nvidia-pcie-wakeup" ''
        grep -qP 'GPP0\s.*\*enabled' /proc/acpi/wakeup && echo GPP0 > /proc/acpi/wakeup || true
      '';
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    SuspendState = "mem";
  };
}
