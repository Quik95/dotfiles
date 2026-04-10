{pkgs, ...}: {
  hardware.xone.enable = true;

  services.udev.packages = [pkgs.game-devices-udev-rules];

  # GameSir G7 SE (VID 3537) enumerates in a transient XUSB mode (PID 10a0)
  # on cold boot. Linux fails to read the configuration descriptor for this
  # mode (EPROTO -71), and the device falls back to a limited HID mode
  # (PID 1082) with no LED or rumble support.
  #
  # These USB quirks alter the enumeration timing so that when the 10a0 mode
  # fails, the device re-enumerates in GIP mode (PID 1073) instead of HID.
  # The xone driver then claims the GIP interface for full functionality.
  #
  # Quirk flags: g = DELAY_INIT, k = NO_LPM, n = DELAY_CTRL_MSG
  boot.kernelParams = ["usbcore.quirks=3537:10a0:gkn"];

  boot.blacklistedKernelModules = ["xpad"];
}
