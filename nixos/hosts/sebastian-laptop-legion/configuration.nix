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

  # Keep Legion on the latest 6.6 LTS kernel while the btmtk regression in the
  # current unstable kernel breaks Bluetooth initialization.
  boot.kernelPackages = pkgs.linuxPackages_6_6;

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
    # The EC signals battery/AC status changes via an ACPI _AEI GpioInt on
    # AMD GPIO pin 4 (gpiochip AMDI0030:00, IRQ 33). It fires every ~20s and
    # spuriously wakes the system from s2idle. acpi.ec_no_wakeup only masks
    # the EC's SCI/GPE3, not this separate GPIO line. Kernel-confirmed via
    # pm_debug_messages: "GPIO 4 is active". This _AEI wake is armed by the
    # ACPI resource, not a device power/wakeup attribute, so the touchpad
    # technique does not apply here. ignore_wake keeps the pin working as a
    # runtime interrupt (battery updates still work) but drops its wake
    # capability. See docs/suspend-wakeup-investigation.md.
    "gpiolib_acpi.ignore_wake=AMDI0030:00@4"
  ];

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  # The FTCS0038 touchpad (i2c-HID via AMD GPIO pin 8 / pinctrl_amd IRQ 7)
  # asserts its interrupt line shortly after s2idle entry and spuriously
  # wakes the system after ~20-25s. Keyboard, power button and lid remain
  # wake sources. See docs/suspend-wakeup-investigation.md.
  #
  # Note: a udev ACTION=="add" rule does not work here because the kernel
  # creates power/wakeup only after the i2c_hid_acpi driver finishes probe(),
  # which is after the udev add event fires. A systemd oneshot is simpler.
  systemd.services.disable-touchpad-wakeup = {
    description = "Disable FTCS0038 touchpad wakeup source (pinctrl_amd IRQ 7)";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "disable-touchpad-wakeup" ''
        echo disabled > /sys/bus/i2c/devices/i2c-FTCS0038:00/power/wakeup
      '';
    };
  };

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
