{pkgs, ...}: {
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = ["/"];
  };

  environment.systemPackages = [
    pkgs.btdu
  ];

  systemd.services.btrfs-quota = {
    description = "Disable btrfs quota groups";
    wantedBy = ["multi-user.target"];
    after = ["home.mount"];
    requires = ["home.mount"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [pkgs.btrfs-progs];
    script = ''
      # Avoid full qgroup accounting overhead with home snapshots.
      btrfs quota disable /home
    '';
  };
}
