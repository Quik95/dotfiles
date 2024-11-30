{
  pkgs,
  unstable,
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

      dither-depth = "auto";

      deband = "yes";
      deband-iterations = 4;
      deband-threshold = 35;
      deband-range = 16;
      deband-grain = 4;

      scale = "ewa_lanczos";
      scale-blur = 0.981251;

      dscale = "catmull_rom";
      correct-downscaling = "yes";
      linear-downscaling = "no";

      cscale = "lanczos";
      sigmoid-upscaling = "yes";

      video-sync = "display-resample";
      interpolation = "yes";
      tscale = "sphinx";
      tscale-blur = 0.6991556596428412;
      tscale-radius = 1.05;
      tscale-clamp = 0.0;

      deinterlace = "no";
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
    };
    scripts = with pkgs.mpvScripts; [
      memo
      autoload
      autocrop
      inhibit-gnome
      autosubsync-mpv
      mpv-playlistmanager
      uosc
      mpris
    ];
    scriptOpts = {
      autosubsync-mpv = {
        ffmpeg_path = "${pkgs.ffmpeg}/bin/ffmpeg";
      };
      mpv-platlistmanager = {
        dynamic_binds = true;
        key_showplaylist = "SHIFT+ENTER";
        key_moveup = "UP";
        key_movedown = "DOWN";
        key_movebegin = "HOME";
        key_moveend = "END";
        key_selectfile = "RIGHT LEFT";
        key_playfile = "ENTER";
        key_removefile = "BS";
        key_closeplaylist = "ESC SHIRT+ENTER";

        filename_replace = ''filename_replace=[{"protocol":{"all":true},"rules":[{"%%(%x%x)":"hex_to_char"}]}]'';
        loadfiles_filetypes = ''loadfiles_filetypes=["jpg","jpeg","png","tif","tiff","gif","webp","svg","bmp","mp3","wav","ogm","flac","m4a","wma","ogg","opus","mkv","avi","mp4","ogv","webm","rmvb","flv","wmv","mpeg","mpg","m4v","3gp"]'';

        loadfiles_on_start = false;
        loadfiles_on_idle_start = false;
        loadfiles_always_append = false;
        sortplaylist_on_file_add = false;

        system = "auto";

        save_playlist_on_file_end = false;

        sync_cursor_on_load = true;
        loop_cursor = true;

        reset_cursor_on_close = true;
        reset_cursor_on_open = true;

        prefer_title = "all";

        youtube_dl_executable = "${unstable.yt-dlp}/bin/yt-dlp";

        resolve_url_titles = true;
        resolve_local_titles = false;
        resolve_title_timeout = 15;
        resolve_title_resolve_limit = 10;
        playlist_display_timeout = 0;
        showamount = -1;

        border = 1;
        style_ass_tags = ''{\q2\an7}'';
        text_padding_x = 30;
        text_padding_y = 60;

        curtain_opacity = 0.0;
        set_title_stripped = false;
        title_suffix = " - mpv";
        slice_longfilenames = false;
        slice_longfilenames_amount = 70;

        playlist_header = ''[%cursor/%plen]'';

        normal_file = ''○ %name'';
        hovered_file = ''● %name'';
        selected_file = ''➔ %name'';
        playing_file = ''▷ %name'';
        playing_hovered_file = ''▶ %name'';
        playing_selected_file = ''➤ %name'';
        display_osd_feedback = true;
      };
    };
  };
}
