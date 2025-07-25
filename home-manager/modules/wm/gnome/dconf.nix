{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["caps:swapescape" "compose:prsc"];
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Alt>q"];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Control>Delete";
      command = "flatpak run be.alexandervanhee.gradia --screenshot=INTERACTIVE";
      name = "Screenshot with gradia";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super>semicolon";
      command = "${pkgs.smile}/bin/smile";
      name = "Open emoji picker";
    };

    "org/gnome/desktop/default-applications" = {
      terminal = "ghostty";
    };

    "org/gnome/desktop/interface" = {
      accent-color = "pink";
      show-battery-percentage = true;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;
      edge-tiling = false;
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "org.gnome.Nautilus.desktop"
        "com.mitchellh.ghostty.desktop"
        "com.google.Chrome.desktop"
        "dev.zed.Zed.desktop"
        "net.nokyan.Resources.desktop"
        "org.gnome.TextEditor.desktop"
      ];
    };

    "org/gnome/desktop/search-providers" = {
      disabled = [
        "org.gnome.Software.desktop"
        "org.gnome.seahorse.Application.desktop"
        "org.gnome.clocks.desktop"
        "org.gnome.Characters.desktop"
        "org.gnome.Calendar.desktop"
        "org.gnome.Nautilus.desktop"
      ];
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-saver-profile-on-low-battery = true;
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-timeout = 900;
      idle-dim = false;
      power-button-action = "suspend";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-schedule-automatic = true;
    };

    "org/gnome/TextEditor" = {
      show-line-numbers = true;
      highlight-current-line = true;
    };

    "it/mijorus/smile" = {
      emoji-size-class = "emoji-button-xxl";
      iconify-on-esc = false;
      load-hidden-on-startup = true;
      tags-locale = "pl";
      use-localized-tags = true;
    };
  };
}
