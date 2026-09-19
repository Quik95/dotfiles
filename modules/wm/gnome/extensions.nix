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

  # Upstream gives every stat 6px of side padding and a 3em label, so five stats
  # crowd the panel and the download figure ends up clipped. The numbers only
  # live in the extension's stylesheet, so rewrite them in a copy instead of
  # overriding the package, which would rebuild all of gnome-shell-extensions.
  compactSystemMonitor = let
    base = pkgs.gnomeExtensions.system-monitor;
  in
    pkgs.runCommand "${base.name}-compact" {
      inherit (base) meta;
      passthru = base.passthru or {} // {inherit (base) extensionUuid;};
    } ''
      cp -r ${base} $out
      chmod -R u+w $out
      css=$out/share/gnome-shell/extensions/${base.extensionUuid}/stylesheet.css
      substituteInPlace $css \
        --replace-fail "padding: 0 6px;" "padding: 0 3px;" \
        --replace-fail "min-width: 3.0em;" "min-width: 2.2em;"
      cat >>$css <<'EOF'

      /* Keep the icon from touching its number now that sections sit closer. */
      .system-monitor-stat-section-label {margin-left: 0.25em;}
      EOF
    '';

  claudeCodexUsage = pkgs.stdenvNoCC.mkDerivation {
    pname = "gnome-shell-extension-claude-codex-usage";
    version = "0.1.0-unstable-2026-06-18";

    src = inputs.gnome-claude-codex-usage;

    patches = [./patches/claude-codex-usage-config-dir.patch];

    nativeBuildInputs = [pkgs.glib];

    buildPhase = ''
      runHook preBuild
      glib-compile-schemas --strict src/schemas
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      extensionDir=$out/share/gnome-shell/extensions/claude-codex-usage@IanBraga96
      mkdir -p "$extensionDir"
      cp -r src/. "$extensionDir/"
      install -Dm644 LICENSE THIRD_PARTY_NOTICES.md -t "$extensionDir"
      runHook postInstall
    '';

    passthru.extensionUuid = "claude-codex-usage@IanBraga96";

    meta = {
      description = "Show Claude Code and Codex CLI usage in the GNOME top bar";
      homepage = "https://github.com/IanBraga96/gnome-claude-codex-usage";
      license = lib.licenses.gpl2Plus;
      platforms = lib.platforms.linux;
    };
  };

  extensions = with pkgs.gnomeExtensions; [
    {
      pkg = activate-window-by-title;
      enabled = false;
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
      pkg = claudeCodexUsage;
      enabled = true;
      dconfPath = "claude-codex-usage";
      settings = {
        show-provider-labels = false;
      };
    }
    {
      pkg = clipboard-indicator;
      enabled = true;
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
        background-menu = false;
        window-preview-caption = false;
        workspace-switcher-should-show = true;
        workspace-switcher-size = 15;
      };
    }
    {
      pkg = launch-new-instance;
      enabled = true;
    }
    {
      pkg = multi-monitor-bar;
      enabled = true;
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
      pkg = removable-drive-menu;
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
