# Timeline snapshots of /home. Everything snapper reads lives here: the
# retention, the timers and who may browse the snapshots (Wisp in the GNOME top
# bar reads them as the user through snapperd). Changing a limit from Wisp's
# preferences would only be overwritten by the next rebuild, so change it here.
{
  # snapper needs a .snapshots subvolume inside the one it snapshots; "v"
  # creates it as a btrfs subvolume, so it never ends up in its own snapshots.
  systemd.tmpfiles.rules = [
    "v /home/.snapshots 0750 root root -"
  ];

  services.snapper = {
    # Catch up on the hourly snapshot after suspend or power-off.
    persistentTimer = true;

    configs.home = {
      SUBVOLUME = "/home";
      FSTYPE = "btrfs";

      ALLOW_USERS = ["sebastian"];
      # Grants ALLOW_USERS an ACL on .snapshots, without which the snapshots are
      # listed but their files cannot be opened.
      SYNC_ACL = true;

      # Snapper limits count snapshots, not age: a day of hourlies plus one
      # snapshot for each of the last seven days.
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 24;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 0;
      TIMELINE_LIMIT_MONTHLY = 0;
      TIMELINE_LIMIT_QUARTERLY = 0;
      TIMELINE_LIMIT_YEARLY = 0;
    };
  };
}
