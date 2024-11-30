{unstable, ...}: {
  programs.yt-dlp = {
    enable = true;
    package = unstable.yt-dlp;
    settings = {
      no-playlist = true;
      ignore-errors = true;
      sub-langs = "en.*,pl.*";
      write-sub = true;
      format = "bestvideo[height<=?1080]+bestaudio/best";
    };
  };
}
