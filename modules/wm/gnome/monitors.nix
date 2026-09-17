{
  pkgs,
  lib,
  ...
}: let
  isGnome = (import ../../../shared/desktop.nix).desktop == "gnome";

  monitorsXml = ./monitors.xml;

  # Reassert the layout whenever mutter writes its own. Comparing first keeps
  # the unit idempotent: the install below re-triggers the path unit, the next
  # run finds the file already matching and exits, so this settles instead of
  # looping.
  restore = pkgs.writeShellScript "gnome-monitors-restore" ''
    target="$HOME/.config/monitors.xml"
    ${pkgs.coreutils}/bin/cmp -s ${monitorsXml} "$target" && exit 0
    ${pkgs.coreutils}/bin/install -m 0644 ${monitorsXml} "$target"
  '';
in
  lib.mkIf isGnome {
    # Monitor layout, modes and per-output scale. GNOME has no dconf keys for
    # this: mutter keeps it all in ~/.config/monitors.xml, the same way Plasma
    # keeps it in kwinoutputconfig.json.
    #
    # The file cannot simply be linked read-only from the store. Mutter saves
    # its whole in-memory config store by writing a temporary file and renaming
    # it over the path, and rename() only needs write permission on ~/.config,
    # so the symlink gets replaced rather than written through -- any display
    # change, a plain hotplug included, silently reverts the layout. Blocking
    # the write outright would mean chattr +i, which needs CAP_LINUX_IMMUTABLE
    # and therefore a system service.
    #
    # So this corrects instead of prevents: mutter's write lands, and the path
    # unit puts the file back. Nothing is lost either way, because mutter only
    # reads monitors.xml at session start -- display changes made in Settings
    # still apply for the current session, they just never outlive it.
    #
    # eDP-1 runs at 1.25 (2048x1280 logical) rather than the 1.2 Plasma used;
    # mutter only offers 1.0, 1.25, 1.333, 1.667 and 2.0 for 2560x1600, and
    # fractional scales at all require the scale-monitor-framebuffer
    # experimental feature set in ./dconf.nix.
    systemd.user.services.gnome-monitors-restore = {
      Unit = {
        Description = "Restore the pinned GNOME monitor layout";
        # The path unit can fire in bursts when mutter rewrites the file
        # several times during a hotplug; never rate-limit ourselves out.
        StartLimitIntervalSec = 0;
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${restore}";
      };
      # Also seed the file at login, so a fresh machine gets the layout without
      # waiting for mutter to touch it first.
      Install.WantedBy = ["default.target"];
    };

    systemd.user.paths.gnome-monitors-restore = {
      Unit.Description = "Watch for mutter rewriting the monitor layout";
      Path.PathChanged = "%h/.config/monitors.xml";
      Install.WantedBy = ["default.target"];
    };
  }
