{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.myHomeManager = {
    # Desktop Environment options
    desktopEnvironment = {
      gnome = {
        enable = mkEnableOption "GNOME desktop environment configuration";
      };
      kde = {
        enable = mkEnableOption "KDE desktop environment configuration";
      };
    };

    # Browser options
    browsers = {
      enable = mkEnableOption "web browsers" // {default = true;};
      firefox = {
        enable = mkEnableOption "Firefox browser";
      };
      chrome = {
        enable = mkEnableOption "Google Chrome browser";
      };
    };

    # IDE and Editor options
    ide = {
      enable = mkEnableOption "IDE and editor tools" // {default = true;};
      nixvim = {
        enable = mkEnableOption "Nixvim (Neovim configuration)";
      };
      helix = {
        enable = mkEnableOption "Helix editor";
      };
      vscode = {
        enable = mkEnableOption "Visual Studio Code";
      };
      jetbrains = {
        enable = mkEnableOption "JetBrains tools";
      };
      zed = {
        enable = mkEnableOption "Zed editor";
      };
      direnv = {
        enable = mkEnableOption "direnv for environment management";
      };
    };

    # Terminal tools options
    terminal = {
      enable = mkEnableOption "terminal tools and utilities" // {default = true;};
      shells = {
        enable = mkEnableOption "shell configurations" // {default = true;};
        fish = {
          enable = mkEnableOption "Fish shell";
        };
      };
      emulators = {
        enable = mkEnableOption "terminal emulators" // {default = true;};
        ghostty = {
          enable = mkEnableOption "Ghostty terminal emulator";
        };
        kitty = {
          enable = mkEnableOption "Kitty terminal emulator";
        };
      };
      git = {
        enable = mkEnableOption "Git configuration" // {default = true;};
      };
      atuin = {
        enable = mkEnableOption "Atuin shell history";
      };
      bat = {
        enable = mkEnableOption "bat (cat with syntax highlighting)";
      };
      btop = {
        enable = mkEnableOption "btop system monitor";
      };
      eza = {
        enable = mkEnableOption "eza (modern ls replacement)";
      };
      starship = {
        enable = mkEnableOption "Starship prompt";
      };
      powerlineGo = {
        enable = mkEnableOption "Powerline-go prompt";
      };
      yazi = {
        enable = mkEnableOption "Yazi file manager";
      };
      zoxide = {
        enable = mkEnableOption "zoxide directory jumper";
      };
    };

    # SDK and development tools
    sdk = {
      enable = mkEnableOption "SDK and development tools" // {default = true;};
      rust = {
        enable = mkEnableOption "Rust development tools";
      };
      c = {
        enable = mkEnableOption "C/C++ development tools";
      };
    };

    # Multimedia options
    multimedia = {
      enable = mkEnableOption "multimedia applications" // {default = true;};
      mpv = {
        enable = mkEnableOption "MPV media player";
      };
      ytDlp = {
        enable = mkEnableOption "yt-dlp video downloader";
      };
      foliate = {
        enable = mkEnableOption "Foliate e-book reader";
      };
    };

    # System integration options
    system = {
      defaultApps = {
        enable = mkEnableOption "default application associations" // {default = true;};
      };
      dropbox = {
        enable = mkEnableOption "Dropbox integration";
      };
      flatpak = {
        enable = mkEnableOption "Flatpak application management";
      };
      sops = {
        enable = mkEnableOption "SOPS secrets management";
      };
      ssh = {
        enable = mkEnableOption "SSH configuration" // {default = true;};
      };
      stylix = {
        enable = mkEnableOption "Stylix theming" // {default = true;};
      };
    };
  };
}
