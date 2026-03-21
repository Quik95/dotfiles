{lib, ...}: {
  dconf.settings = {
    # OLED protection: blank screen after 3 minutes of inactivity
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 180;
    };
  };
}
