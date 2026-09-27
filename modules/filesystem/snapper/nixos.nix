{
  systemd.tmpfiles.rules = [
    "v /home/.snapshots 0750 root root -"
  ];

  services.snapper = {
    persistentTimer = true;

    configs.home = {
      SUBVOLUME = "/home";
      FSTYPE = "btrfs";

      ALLOW_USERS = ["sebastian"];
      # Grants ALLOW_USERS an ACL on .snapshots, without which the snapshots are
      # listed but their files cannot be opened.
      SYNC_ACL = true;

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
