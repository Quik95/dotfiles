{
  pkgs,
  lib,
  ...
}: let
  isGnome = (import ../../../shared/desktop.nix).desktop == "gnome";
in
  lib.mkIf isGnome {
    dconf.settings = {
      "org/gnome/desktop/input-sources" = {
        # Matches the Plasma keyboard layout (modules/wm/plasma/behavior.nix)
        # and the pl2 console keymap from nixos/common.nix.
        sources = [(lib.hm.gvariant.mkTuple ["xkb" "pl"])];
        xkb-options = [];
      };

      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Alt>q"];
      };

      "org/gnome/desktop/wm/preferences" = {
        focus-mode = "sloppy";
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

      "org/gnome/desktop/session" = {
        # OLED protection: blank the screen after 3 minutes of inactivity, the
        # same as Plasma does via powerdevil turnOffDisplay.idleTimeout.
        idle-delay = lib.mkDefault (lib.hm.gvariant.mkUint32 180);
      };

      "org/gnome/mutter" = {
        # Plasma runs the 2560x1600 panel at 120%; mutter only offers fractional
        # scales once the monitor framebuffer is scaled instead of the output.
        # The per-monitor scale itself is runtime state in ~/.config/monitors.xml,
        # the same way Plasma keeps it in kwinoutputconfig.json.
        experimental-features = ["scale-monitor-framebuffer"];
        dynamic-workspaces = true;
        workspaces-only-on-primary = false;
        edge-tiling = false;
      };

      "org/gnome/shell" = {
        favorite-apps = [
          "org.gnome.Nautilus.desktop"
          "com.mitchellh.ghostty.desktop"
          "firefox.desktop"
          "mpv.desktop"
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
        sleep-inactive-ac-type = "suspend";
        sleep-inactive-ac-timeout = 1800;
        sleep-inactive-battery-type = "suspend";
        sleep-inactive-battery-timeout = 1800;
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
