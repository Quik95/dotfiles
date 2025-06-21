{config, ...}: {
  programs.yt-dlp = {
    enable = true;
    settings = {
      no-playlist = true;
      ignore-errors = true;
      sub-langs = "en.*,pl.*";
      write-sub = true;
      format = "(bestvideo[height<=1080][vcodec*=h264]+bestaudio)/(bestvideo[height<=1080][vcodec!*=vp9]+bestaudio)/(bestvideo[height<=1080]+bestaudio)/best[height<=1080]";
      cookies-from-browser = "chrome:${config.home.homeDirectory}/.var/app/com.google.Chrome/";
    };
  };
}
