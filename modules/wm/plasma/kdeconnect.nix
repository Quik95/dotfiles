{lib, ...}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";

  # The phone paired with GSConnect (modules/wm/gnome/extensions.nix); KDE
  # Connect keys per-device settings by the same remote device ID.
  phoneDeviceId = "509f37abcafb46e6bb3dde9fc301c07d";

  # Same feature set GSConnect leaves on: battery, connectivity, find my phone,
  # remote input, presenter and sharing. Everything else stays off until
  # explicitly enabled here, including KDE-only plugins GSConnect lacks.
  enabledPlugins = [
    "battery"
    "connectivity_report"
    "findmyphone"
    "findthisdevice"
    "mousepad"
    "presenter"
    "share"
  ];
  disabledPlugins = [
    "clipboard"
    "contacts"
    "digitizer"
    "lockdevice"
    "mmtelephony"
    "mpriscontrol"
    "mprisremote"
    "notifications"
    "pausemusic"
    "ping"
    "remotecommands"
    "remotecontrol"
    "remotekeyboard"
    "remotesystemvolume"
    "runcommand"
    "screensaver_inhibit"
    "sendnotifications"
    "sftp"
    "shareinputdevices"
    "shareinputdevicesremote"
    "sms"
    "systemvolume"
    "telephony"
    "virtualmonitor"
  ];
in {
  config = lib.mkIf isPlasma {
    # kdeconnectd reads [Plugins] <id>Enabled from the device's config file and
    # falls back to each plugin's EnabledByDefault, so every plugin is listed.
    programs.plasma.configFile."kdeconnect/${phoneDeviceId}/config".Plugins =
      lib.genAttrs (map (p: "kdeconnect_${p}Enabled") enabledPlugins) (_: true)
      // lib.genAttrs (map (p: "kdeconnect_${p}Enabled") disabledPlugins) (_: false);
  };
}
