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
    description = "Enable btrfs quota groups";
    wantedBy = ["multi-user.target"];
    after = ["home.mount"];
    requires = ["home.mount"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [pkgs.btrfs-progs];
    script = ''
      btrfs qgroup show /home >/dev/null 2>&1 || btrfs quota enable /home
    '';
  };
}
