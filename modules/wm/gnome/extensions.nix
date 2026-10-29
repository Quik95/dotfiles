{
  pkgs,
  lib,
  inputs,
  ...
}: let
  isGnome = (import ../../../shared/desktop.nix).desktop == "gnome";

  gsconnectDeviceId = "509f37abcafb46e6bb3dde9fc301c07d";
  gsconnectDisabledPlugins = [
    "clipboard"
    "contacts"
    "mpris"
    "notification"
    "ping"
    "runcommand"
    "sftp"
    "sms"
    "systemvolume"
    "telephony"
  ];

  # The gcampax extensions on extensions.gnome.org track the next shell
  # release (51 while nixpkgs ships shell 50), so GNOME marks them out of
  # date. Until nixpkgs ships shell 51, take the copies bundled with
  # gnome-shell-extensions, which match the shell, one directory at a time so
  # the others stay out of the profile. From 51 on this falls back to the
  # extensions.gnome.org package by itself and a warning asks to drop it.
  gcampaxFromBundle = lib.versionOlder pkgs.gnome-shell.version "51";
  gcampaxExtension = name: fallback:
    if gcampaxFromBundle
    then let
      uuid = "${name}@gnome-shell-extensions.gcampax.github.com";
      base = pkgs.gnome-shell-extensions;
    in
      pkgs.runCommand "gnome-shell-extension-${name}-${base.version}" {
        inherit (base) meta;
        passthru.extensionUuid = uuid;
      } ''
        mkdir -p $out/share/gnome-shell/extensions
        cp -r ${base}/share/gnome-shell/extensions/${uuid} $out/share/gnome-shell/extensions/
      ''
    else fallback;

  # Blur my Shell 75 added popup blur, on by default. Without a blur effect
  # that supports rounded corners (rounded-blur-found=false; GNOME 51's
  # Shell.BlurEffect has none either) it paints a square blurred box behind
  # the rounded quick settings and menus. Keep it off only on 75: any other
  # version turns it back on and a warning asks to check the corners.
  popupBlurBroken = pkgs.gnomeExtensions.blur-my-shell.version == "75";

  # GNOME caps the right panel box at half the bar, and with every indicator
  # there the network figures got squeezed into "0.1 …". Upstream always adds
  # the monitor to the right box, so place it in the left one, right after the
  # hidden Activities button. Upstream also gives every stat 6px of side
  # padding and a 3em label; tighten those too. Both edits rewrite a
  # copy instead of overriding the package, which would rebuild all of
  # gnome-shell-extensions.
  compactSystemMonitor = let
    base = gcampaxExtension "system-monitor" pkgs.gnomeExtensions.system-monitor;
  in
    pkgs.runCommand "${base.name}-compact" {
      inherit (base) meta;
      passthru = base.passthru or {} // {inherit (base) extensionUuid;};
    } ''
      cp -r ${base} $out
      chmod -R u+w $out
      dir=$out/share/gnome-shell/extensions/${base.extensionUuid}
      substituteInPlace $dir/extension.js \
        --replace-fail "Main.panel.addToStatusArea(this.uuid, this._indicator);" \
          "Main.panel.addToStatusArea(this.uuid, this._indicator, 1, 'left');"
      css=$dir/stylesheet.css
      substituteInPlace $css \
        --replace-fail "padding: 0 6px;" "padding: 0 3px;" \
        --replace-fail "min-width: 3.0em;" "min-width: 2.2em;"
      cat >>$css <<'EOF'

      /* Keep the icon from touching its number now that sections sit closer. */
      .system-monitor-stat-section-label {margin-left: 0.25em;}
      EOF
    '';

  # Super+P "Join Displays" otherwise puts the primary HDMI monitor left of
  # the laptop; see stored-display-switcher/extension.js.
  storedDisplaySwitcher = let
    uuid = "stored-display-switcher@sebastian";
  in
    pkgs.runCommand "gnome-shell-extension-stored-display-switcher" {
      passthru.extensionUuid = uuid;
    } ''
      install -Dm644 -t $out/share/gnome-shell/extensions/${uuid} ${./stored-display-switcher}/*
    '';

  extensions = with pkgs.gnomeExtensions; [
    {
      pkg = activate-window-by-title;
      enabled = false;
    }
    {
      pkg = inputs.gnome-ai-usage.packages.${pkgs.stdenv.hostPlatform.system}.default;
      enabled = true;
      dconfPath = "ai-usage";
      settings = {
        # Same as the Plasma widget had: both providers fetched and pinned,
        # polled every minute.
        enabled-providers = ["claude" "openai"];
        panel-providers = ["claude" "openai"];
        poll-interval = lib.hm.gvariant.mkUint32 60;
        show-overview = false;
        show-spend = false;
      };
    }
    {
      pkg = appindicator;
      enabled = true;
    }
    {
      pkg = bluetooth-quick-connect;
      enabled = true;
      dconfPath = "bluetooth-quick-connect";
      settings = {
        keep-menu-on-toggle = true;
        show-battery-value-on = true;
      };
    }
    {
      pkg = brightness-control-using-ddcutil;
      enabled = true;
      dconfPath = "display-brightness-ddcutil";
      settings = {
        # As its own panel button the extension inserts itself at index 0 of the
        # right box, exactly like system-monitor, so their relative order depends
        # on which one happens to be enabled first. Living in the Quick Settings
        # indicator cluster instead keeps it right of the resource monitor for
        # good, and position-system-indicator pins it to the end of that cluster.
        button-location = 1;
        position-system-indicator = 15.0;
      };
    }
    {
      pkg = blur-my-shell;
      enabled = true;
      dconfPath = "blur-my-shell/popup";
      settings.blur = !popupBlurBroken;
    }
    {
      pkg = caffeine;
      enabled = true;
      dconfPath = "caffeine";
      settings = {
        show-notifications = false;
      };
    }
    {
      pkg = clipboard-indicator;
      enabled = true;
    }
    {
      pkg = dash-to-panel;
      enabled = true;
      dconfPath = "dash-to-panel";
      settings = {
        # Global fallback for every monitor; per-monitor panel-positions stays
        # empty so it applies to the laptop panel and the HDMI one alike.
        panel-position = "TOP";
        # Global fallback like panel-position; the default 48px is much taller
        # than the stock GNOME bar.
        panel-size = 32;
        # Pinned favorite launchers first, then one button per open window
        # with its title.
        group-apps = false;
        show-favorites = true;
        # Each monitor's taskbar lists only the windows on that monitor.
        isolate-monitors = true;
        # Dash to Panel hides the overview dash by default; keep the stock one
        # in the overview as well.
        stockgs-keep-dash = true;
        # Middle click closes that one window, like a browser tab: with
        # group-apps off, QUIT deletes only the clicked window. Shift+middle
        # still launches a new instance.
        middle-click-action = "QUIT";
        # Window list top-left, clock centered, every indicator box on the
        # right, matching the stock bar. Keyed by monitor index (eDP-1 and
        # HDMI-1); Dash to Panel falls back to the index when no serial entry
        # exists.
        panel-element-positions = builtins.toJSON (lib.genAttrs ["0" "1"] (_: [
          {
            element = "showAppsButton";
            visible = false;
            position = "stackedTL";
          }
          {
            element = "activitiesButton";
            visible = false;
            position = "stackedTL";
          }
          {
            element = "taskbar";
            visible = true;
            position = "stackedTL";
          }
          {
            element = "dateMenu";
            visible = true;
            position = "centerMonitor";
          }
          {
            element = "leftBox";
            visible = true;
            position = "stackedBR";
          }
          {
            element = "centerBox";
            visible = true;
            position = "stackedBR";
          }
          {
            element = "rightBox";
            visible = true;
            position = "stackedBR";
          }
          {
            element = "systemMenu";
            visible = true;
            position = "stackedBR";
          }
          {
            element = "desktopButton";
            visible = false;
            position = "stackedBR";
          }
        ]));
      };
    }
    {
      pkg = fullscreen-hot-corner;
      enabled = true;
    }
    {
      # The package itself comes from programs.kdeconnect in
      # modules/wm/gnome/nixos.nix, which is also what opens the firewall ports;
      # the entry here only enables and configures the shell extension.
      pkg = gsconnect;
      enabled = true;
      dconfPath = "gsconnect";
      settings = {
        # Keep GSConnect available for the existing pairing, but make it inert
        # unless its functionality is explicitly enabled again below.
        show-indicators = false;
        keep-alive-when-locked = false;
        create-native-messaging-hosts = false;
        debug = false;
        discoverable = false;
      };
    }
    {
      pkg = just-perfection;
      enabled = true;
      dconfPath = "just-perfection";
      settings = {
        activities-button = false;
        search = false;
        workspace-wrap-around = false;
        window-demands-attention-focus = true;
        # Stored as pixels + 1 (0 keeps the shell's default padding), so 5 means
        # 4px per side, which closes the wide gaps between top-bar buttons.
        panel-button-padding-size = 5;
        background-menu = false;
        window-preview-caption = false;
        workspace-switcher-should-show = true;
        workspace-switcher-size = 15;
      };
    }
    {
      pkg = gcampaxExtension "launch-new-instance" launch-new-instance;
      enabled = true;
    }
    {
      # Dash to Panel draws its own panel on every monitor.
      pkg = multi-monitor-bar;
      enabled = false;
      dconfPath = "multi-monitors-bar";
      settings = {
        show-panel = true;
        show-activities = false;
        show-date-time = true;
        show-indicator = false;
        show-overview-on-extended-monitors = false;
        show-dock-on-extended-monitors = false;
      };
    }
    {
      pkg = random-wallpaper;
      enabled = false;
    }
    {
      pkg = gcampaxExtension "drive-menu" removable-drive-menu;
      enabled = true;
    }
    {
      pkg = smile-complementary-extension;
      enabled = true;
    }
    {
      pkg = compactSystemMonitor;
      enabled = true;
    }
    {
      pkg = storedDisplaySwitcher;
      enabled = true;
    }
  ];

  mkDconfSettings = exts:
    lib.foldl' (
      acc: ext:
        if ext ? "settings" && ext ? "dconfPath"
        then acc // {"org/gnome/shell/extensions/${ext.dconfPath}" = ext.settings;}
        else acc
    ) {}
    exts;
in
  lib.mkIf isGnome {
    warnings =
      lib.optional (!gcampaxFromBundle) "extensions.nix: GNOME Shell is now ${pkgs.gnome-shell.version}; the gcampax extensions come from extensions.gnome.org again, remove `gcampaxFromBundle`/`gcampaxExtension`."
      ++ lib.optional (!popupBlurBroken) "extensions.nix: Blur my Shell is now ${pkgs.gnomeExtensions.blur-my-shell.version} and popup blur is back on; if quick settings show no square box behind them, remove `popupBlurBroken` and the blur-my-shell/popup setting.";

    dconf.settings =
      mkDconfSettings extensions
      // {
        "org/gnome/shell/extensions/gsconnect/device/${gsconnectDeviceId}" = {
          disabled-plugins = gsconnectDisabledPlugins;
          menu-actions = [];
        };
        "org/gnome/shell" = {
          disable-user-extensions = false;
          disabled-extensions = [];
          enabled-extensions =
            lib.map (ext: ext.pkg.extensionUuid)
            (lib.filter (ext: ext.enabled) extensions);
        };
      };

    home.packages = (lib.map (ext: ext.pkg) extensions) ++ (with pkgs; [ddcutil]);
  }
