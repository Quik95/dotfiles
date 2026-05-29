{pkgs, ...}: {
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # MT7925 BT (0489:e111) becomes unresponsive after a USB autosuspend cycle:
  # on resume the chip needs a full firmware re-setup and ends up flapping in a
  # reset loop until a cold power cycle (Red Hat BZ 2372880). Stop btusb from
  # enabling autosuspend on it. Patrz docs/wifi-mt7925-investigation.md.
  boot.extraModprobeConfig = "options btusb enable_autosuspend=0";

  # Foxconn MT7925 BT (0489:e111) is misdetected as an MTP device.
  # The MTP volume monitor races btusb for the USB device at boot; if it
  # wins, the BT firmware handshake fails (wmt func ctrl) and the chip is
  # stuck until a cold power cycle. Mask the monitor unconditionally — the
  # gnome.enable guard left this disabled on Plasma, which is the desktop
  # this host actually runs.
  systemd.user.services.gvfs-mtp-volume-monitor.enable = false;

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "btusb-mt7925-udev";
      text = ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0489", ATTRS{idProduct}=="e111", ENV{ID_MTP_DEVICE}="0", ENV{ID_MEDIA_PLAYER}="0", ENV{MTP_NO_PROBE}="1", ENV{UDISKS_IGNORE}="1"
        ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0489", ATTR{idProduct}=="e111", RUN+="${pkgs.kmod}/bin/modprobe btusb", RUN+="${pkgs.bash}/bin/bash -c 'echo 0489 e111 > /sys/bus/usb/drivers/btusb/new_id 2>/dev/null; true'"
      '';
      destination = "/etc/udev/rules.d/68-btusb-mt7925.rules";
    })
  ];
}
