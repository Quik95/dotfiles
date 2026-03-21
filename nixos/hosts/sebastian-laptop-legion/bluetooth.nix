{pkgs, ...}: {
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Foxconn MT7925 BT (0489:e111) not auto-bound by btusb.
  # gvfsd-mtp in the user session claims the USB device via usbfs.
  # Mask the MTP volume monitor so it never starts, and register the
  # device ID with btusb via udev.
  systemd.user.services.gvfs-mtp-volume-monitor.enable = false;

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "btusb-mt7925-udev";
      text = ''
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0489", ATTR{idProduct}=="e111", ENV{MTP_NO_PROBE}="1", RUN+="${pkgs.kmod}/bin/modprobe btusb", RUN+="${pkgs.bash}/bin/bash -c 'echo 0489 e111 > /sys/bus/usb/drivers/btusb/new_id 2>/dev/null; true'"
      '';
      destination = "/etc/udev/rules.d/68-btusb-mt7925.rules";
    })
  ];
}
