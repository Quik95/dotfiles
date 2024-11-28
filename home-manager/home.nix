# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  home = {
    username = "sebastian";
    homeDirectory = "/home/sebastian";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  # home.packages = with pkgs; [ steam ];
  home.packages = with pkgs; [
    fortune-kind
    ffmpeg-full

    unstable.yt-dlp
  ];

  # Enable home-manager and git
  programs.home-manager.enable = true;
  home.sessionVariables = {
    BROWSER = "firefox";
    VISUAL = "zeditor";
    EDITOR = "nvim";
    PAGER = "bat";
    TERMINAL = "kitty";
  };

  programs.git = {
    enable = true;
    userName = "Sebastian Bartoszewicz";
    userEmail = "quikstyletv@gmail.com";
  };
  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  programs.kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    themeFile = "Catppuccin-Frappe";
    font = {
      size = 16;
      name = "DejaVuSansMono";
    };
    settings = {
      "disable_ligatures" = "never";
      "scrollback_lines" = 1000000;
      "scrollback_pager" = "bat";
      "copy_on_select" = "no";
      "paste_actions" = "quote-urls-at-prompt";
      "strip_trailing_spaces" = "smart";
      "sync_to_monitor" = "yes";
      "enable_audio_bell" = "no";
      "tab_bar_style" = "powerline";
      "background_opacity" = 0.9;
    };
  };

  programs.fish = {
    enable = true;
    shellAbbrs = {
      mkdir = "mkdir -p";
      rm = "rm -I";
      cp = "cp -riv";
      du = "du -sh";
      copy = "wl-copy <";
      drsync = "rsync --archive --verbose --progress --partial --info=progress2 --human-readable --no-inc-search";
      fP = "fish --private";
      icat = "kitty +kitten icat";
      ytt = "yt-dlp --format \'bestvideo[height<=?1080]+bestaudio/best\' -P /tmp/";

      plog = "git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(auto)%d%C(reset)' --all";
      gs = "git status";
    };
    shellAliases = {
      ls = "eza -ahm -F --git --icons --no-permissions --no-user";
    };
    interactiveShellInit = ''
      function fish_greeting
        fortune-kind
      end
    '';
  };

  programs.powerline-go = {
    enable = true;
    newline = false;
    modules = [
      "venv"
      "user"
      "host"
      "ssh"
      "cwd"
      "perms"
      "git"
      "exit"
      "root"
      "nix-shell"
    ];
    settings = {
      theme = "gruvbox";
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.bat = {
    enable = true;
    config = {"theme" = "TwoDark";};
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.btop = {
    enable = true;
    settings = {
      theme = "Tokyo Storm";
      theme_background = true;
      true_color = true;
      presets = "cpu:1:default,proc:0:default cpu:0:default,mem:0:default,net:0:default cpu:0:block,net:0:tty";
      round_corners = true;
      graph_symbol = "braille";
      show_boxes = "cpu mem net proc";
      update_ms = 1500;
      proc_sorting = "cpu lazy";
    };
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
  };

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

  programs.neovim = {
    enable = true;
  };

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
