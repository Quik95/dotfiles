{
  pkgs,
  ...
}: {
  programs.mpv = {
    enable = true;
    bindings = {
      MOUSE_BTN0 = "ignore";
      MOUSE_BTN2 = "cycle pause";

      AXIS_UP = "ignore";
      AXIS_DOWN = "ignore";
      AXIS_LEFT = "ignore";
      AXIS_RIGHT = "ignore";

      RIGHT = "osd-msg-bar seek +5 relative+keyframes";
      LEFT = "osd-msg-bar seek -5 relative+keyframes";
      "SHIFT+RIGHT" = "osd-msg-bar seek +1 relative+exact";
      "SHIFT+LEFT" = "osd-msg-bar seek -1 relative+exact";
      "CTRL+RIGHT" = ''frame-step ; show-text "Frame: ''${estimated-frame-number} / ''${estimated-frame-count}"'';
      "CTRL+LEFT" = ''frame-back-step ; show-text "Frame: ''${estimated-frame-number} / ''${estimated-frame-count}"'';

      UP = "osd-msg-bar seek +30 relative+keyframes";
      DOWN = "osd-msg-bar seek -30 relative+keyframes";

      "ALT+RIGHT" = ''sub-seek +1 ; show-text "Sub Seek +1"'';
      "ALT+LEFT" = ''sub-seek -1 ; show-text "Sub Seek -1"'';

      "9" = ''add volume -2 ; show-text "Volume: ''${volume}"'';
      "0" = ''add volume +2 ; show-text "Volume: ''${volume}"'';

      "!" = "cycle ontop";

      "`" = "ignore";
      "~" = "ignore";
      "#" = "ignore";
      "$" = "ignore";
      "%" = "ignore";
      "^" = "ignore";
      "&" = "ignore";
      "*" = "ignore";

      "[" = "add speed -0.1";
      "]" = "add speed +0.1";

      Q = "quit";

      i = "script-binding stats/display-stats";
      I = "script-binding stats/display-stats-toggle";

      s = "cycle sub";
      S = "cycle sub-visibility";

      f = ''cycle fullscreen ; show-text "Scale: ''${window-scale}"'';

      n = "add audio-delay +0.10";
      N = "add audio-delay -0.10";

      m = "add sub-delay +0.10";
      M = "add sub-delay -0.10";

      ESC = "cycle fullscreen";
      SPACE = "cycle pause";
      ENTER = "show-progress";

      BS = "revert-seek";

      F1 = "script-binding console/enable";
      F12 = ''af toggle "lavfi=[loudnorm=I=-22:TP=-1.5:LRA=2]"'';
    };
    config = {
      save-position-on-quit = true;
      force-seekable = true;

      cache = true;
      demuxer-max-bytes = "4096MiB";

      prefetch-playlist = true;
      drag-and-drop = "append";

      gpu-api = "vulkan";

      hr-seek-framedrop = "no";
      border = "no";
      msg-color = "yes";
      msg-module = "yes";

      keep-open = "yes";
      cursor-autohide = 1000;

      screenshot-format = "png";
      screenshot-png-compression = 4;
      screenshot-tag-colorspace = "yes";
      screenshot-high-bit-depth = "yes";

      blend-subtitles = "no";
      sub-ass-use-video-data = "all";
      sub-ass-scale-with-window = "no";
      sub-auto = "fuzzy";
      demuxer-mkv-subtitle-preroll = "yes";
      embeddedfonts = "yes";
      sub-fix-timing = "yes";

      volume-max = 130;
      audio-stream-silence = true;
      audio-file-auto = "fuzzy";
      audio-pitch-correction = "yes";

      profile = "high-quality";
      hwdec = "auto";
      vo = "gpu-next";

      dither = "fruit";
      dither-depth = "auto";

      deband = "yes";
      deband-iterations = 4;
      deband-threshold = 35;
      deband-range = 16;
      deband-grain = 4;

      correct-downscaling = "yes";

      linear-upscaling = "no";
      sigmoid-upscaling = "yes";
      linear-downscaling = "yes";

      video-sync = "display-resample";
      interpolation = "yes";
      tscale = "mitchell";

      deinterlace = "no";

      ytdl = true;
      ytdl-format = "(bestvideo[height<=1080][vcodec*=h264]+bestaudio)/(bestvideo[height<=1080][vcodec!*=vp9]+bestaudio)/(bestvideo[height<=1080]+bestaudio)/best[height<=1080]";
    };
    profiles = {
      "protocol.http" = {
        hls-bitrate = "max";
      };

      "protocol.https" = {
        profile = "protocol.http";
      };

      "protocol.ytdlp" = {
        profile = "protocol.http";
      };

      "high-res-output" = {
        scale = "catmull_rom";
        dscale = "hermite";
        cscale = "catmull_rom";
        temporal-dither = "yes";
        dither = "fruit";
        deband = "yes";
        deband-iterations = 1;
        deband-threshold = 32;
      };
    };
    scripts = with pkgs.mpvScripts; [
      autocrop
      autoload
      autosubsync-mpv
      inhibit-gnome
      memo
      mpris
      mpv-playlistmanager
      quack
      sponsorblock-minimal
      uosc
    ];
    scriptOpts = {
      autosubsync-mpv = {
        ffmpeg_path = "${pkgs.ffmpeg}/bin/ffmpeg";
      };
      memo = {
        H = "script-binding memo-history";
      };
      playlistmanager = {
        prefer_titles = "all";
        youtube_dl_executable = "${pkgs.yt-dlp}/bin/yt-dlp";
        resolve_url_titles = true;
      };
    };
  };
}
