{
  programs.yt-dlp = {
    enable = true;
    settings = {
      no-playlist = true;
      ignore-errors = true;
      sub-langs = "en.*,pl.*";
      write-sub = true;
      format = "bestvideo[height<=?1080]+bestaudio/best";
    };
  };
}
