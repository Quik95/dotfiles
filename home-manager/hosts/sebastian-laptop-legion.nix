{lib, ...}: {
  programs.mangohud = {
    enable = true;
    settings = {
      position = "bottom-left";
      fps = true;
      frametime = true;
      gpu_stats = true;
      gpu_temp = true;
      vram = true;
      cpu_stats = true;
      cpu_temp = true;
      ram = true;
    };
  };

  programs.mpv.config = {
    ytdl-format = lib.mkForce "(bestvideo[height<=1600][vcodec*=h264]+bestaudio)/(bestvideo[height<=1600][vcodec!*=vp9]+bestaudio)/(bestvideo[height<=1600]+bestaudio)/best[height<=1600]";
  };
}
