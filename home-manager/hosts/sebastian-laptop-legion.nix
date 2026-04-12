{lib, ...}: {
  programs.mpv.config = {
    ytdl-format = lib.mkForce "(bestvideo[height<=1600][vcodec*=h264]+bestaudio)/(bestvideo[height<=1600][vcodec!*=vp9]+bestaudio)/(bestvideo[height<=1600]+bestaudio)/best[height<=1600]";
  };
}
