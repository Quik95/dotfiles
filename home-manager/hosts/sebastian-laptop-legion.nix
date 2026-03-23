{lib, ...}: {
  programs.mpv.config = {
    ytdl-format = lib.mkForce "(bestvideo[height<=1600][vcodec*=h264]+bestaudio)/(bestvideo[height<=1600][vcodec!*=vp9]+bestaudio)/(bestvideo[height<=1600]+bestaudio)/best[height<=1600]";
  };

  dconf.settings = {
    # OLED protection: blank screen after 3 minutes of inactivity
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 180;
    };
  };
}
