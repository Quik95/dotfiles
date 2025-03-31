{
  dconf.settings = {
    "org/gnome/desktop/input-sources" = {
      xkb-options = ["terminate:ctrl_alt_bksp" "caps:swapescape" "compose:prsc"];
    };

    "org/gnome/desktop/wm/keybindings" = {
      close = ["<Alt>q"];
    };

    "org/gnome/desktop/default-applications" = {
      terminal = "ghostty";
    };

    "org/gnome/desktop/interface" = {
      accent-color = "pink";
      "show-battery-percentage" = true;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      workspaces-only-on-primary = true;
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
  };
}
