{pkgs, ...}: {
  programs.mpv = {
    enable = true;
    bindings = {
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
    };
  };
}
