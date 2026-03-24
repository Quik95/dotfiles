{lib, ...}: {
  boot.kernelParams = [
    "zswap.enabled=1"
    "zswap.compressor=zstd"
    "zswap.shrinker_enabled=1"
  ];

  fileSystems."/swap" = {
    device = "/dev/disk/by-uuid/332b254c-7d52-4899-bfda-4207bac52c49";
    fsType = "btrfs";
    options = ["subvol=@swap"];
  };

  swapDevices = lib.mkForce [{
    device = "/swap/swapfile";
  }];

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 3;
    "vm.vfs_cache_pressure" = 125;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };
}
