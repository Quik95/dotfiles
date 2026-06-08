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

  # mt7925e (WiFi) jest w mainline od 6.7; regresja inicjalizacji BT MT7925 (wmt func ctrl -22) naprawiona upstream w 7.0.10 — stockowy kernel wystarcza. Patrz docs/wifi-mt7925-investigation.md.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    # The GPIO controller AMDI0030:00 (\_SB.GPIO) exposes several ACPI _AEI
    # GpioInt lines that spuriously wake s2idle (pm_wakeup_irq=7, pinctrl_amd).
    # acpi.ec_no_wakeup only masks the EC's SCI/GPE3, not these separate GPIO
    # lines. ignore_wake drops a pin's wake capability while keeping it working
    # as a runtime interrupt. Pins decoded from the _EVT method in SSDT27
    # (iasl -d); lid / power button / AC / battery all route through pin #0
    # (EC0.HWAK multiplexer), which is deliberately NOT masked so the lid and
    # power button still wake the system. Masked device-wake lines:
    #   @4  -> GPP0.PEGP (NVIDIA dGPU info change; fired every ~20s)
    #   @5  -> GPP0.PEGP (NVIDIA dGPU, sibling of #4)
    #   @24 -> GPP2 (PCIe device wake)
    #   @58 -> GP17.XHC0 (USB controller device wake)
    #   @59 -> GP17.XHC1 (USB controller device wake)
    # Trade-off: the laptop no longer wakes from USB-device activity, a PCIe
    # device event, or a dGPU event while suspended (intended for closed-lid
    # sleep). See docs/suspend-wakeup-investigation.md (Próba 5 + dekodowanie DSDT).
    "gpiolib_acpi.ignore_wake=AMDI0030:00@4,AMDI0030:00@5,AMDI0030:00@24,AMDI0030:00@58,AMDI0030:00@59"
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

  # Diagnostic: after the 2026-05-30 kernel bump (linuxPackages_latest) the
  # intermittent s2idle false-wake returned (pm_wakeup_irq=7, a pinctrl_amd
  # GPIO). pm_debug_messages is a runtime sysfs toggle, off by default, so the
  # kernel never logged "GPIO N is active" for the failing cycles. Enable it at
  # boot so the next false-wake names the offending pin in the journal; then
  # add that pin to gpiolib_acpi.ignore_wake above. Remove once pinned down.
  # See docs/suspend-wakeup-investigation.md (Próba 5).
  systemd.services.enable-pm-debug-messages = {
    description = "Enable kernel PM debug messages (logs waking GPIO on resume)";
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "enable-pm-debug-messages" ''
        echo 1 > /sys/power/pm_debug_messages
      '';
    };
  };

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    SuspendState = "mem";
  };
}
