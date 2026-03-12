{lib, ...}: let
  lenovoConservation = {
    enable = true;
    mode = 1; # 1 = conservation on (~80%), 0 = off (charge to 100%)
  };
in {
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ../../common.nix
  ];

  networking.hostName = "sebastian-laptop-loq";
  dotfiles.eduroam.interfaceName = "wlp9s0";
  dotfiles.i2c.enable = true;
  dotfiles.passwordless-sudo.enable = false;

  # --- PAMIĘĆ I SWAP ---
  zramSwap = {
    enable = true;
    memoryPercent = 50;
    algorithm = "zstd";
  };

  swapDevices = lib.mkForce [
    {
      device = "/swap/swapfile";
      size = 18432; # 18 GB, aby pomieścić zrzut RAM podczas hibernacji
    }
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 125;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  # --- HIBERNACJA I ZARZĄDZANIE ENERGIĄ ---
  boot.resumeDevice = "/dev/disk/by-uuid/17c79fd8-ce47-40f6-8953-c926267eb013";
  boot.kernelParams = ["resume_offset=47286090"];

  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "120m";
    SuspendState = "mem";
  };

  # Clone MAC address from HP laptop for network allow-list compatibility
  networking.networkmanager.ethernet.macAddress = "c8:5a:cf:df:08:f8";

  assertions = [
    {
      assertion = builtins.elem lenovoConservation.mode [0 1];
      message = "lenovoConservation.mode must be 0 or 1.";
    }
  ];

  # Lenovo LOQ/IdeaPad family exposes a boolean conservation mode in sysfs.
  # 1 = on (fixed vendor threshold, usually ~80%), 0 = off (charge to 100%).
  systemd.services =
    if lenovoConservation.enable
    then {
      lenovo-conservation-mode = {
        description = "Set Lenovo battery conservation mode";
        wantedBy = ["multi-user.target"];
        after = ["local-fs.target"];
        unitConfig.ConditionPathExistsGlob = "/sys/bus/platform/drivers/ideapad_acpi/VPC2004:*/conservation_mode";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          NoNewPrivileges = true;
          PrivateTmp = true;
          PrivateDevices = true;
          PrivateNetwork = true;
          ProtectSystem = "strict";
          ProtectHome = true;
          ProtectControlGroups = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectClock = true;
          ProtectHostname = true;
          MemoryDenyWriteExecute = true;
          LockPersonality = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;
          RestrictNamespaces = true;
          RestrictAddressFamilies = ["AF_UNIX"];
          IPAddressDeny = "any";
          ProtectProc = "invisible";
          ProcSubset = "pid";
          CapabilityBoundingSet = "";
          AmbientCapabilities = "";
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "@system-service"
            "~@privileged"
            "~@resources"
            "~@mount"
            "~@swap"
            "~@reboot"
            "~@obsolete"
            "~@debug"
            "~@cpu-emulation"
            "~@module"
            "~@raw-io"
            "~@clock"
          ];
          UMask = "0077";
          ReadWritePaths = ["/sys/bus/platform/drivers/ideapad_acpi"];
        };
        script = ''
          for f in /sys/bus/platform/drivers/ideapad_acpi/VPC2004:*/conservation_mode; do
            if [ -w "$f" ]; then
              echo ${toString lenovoConservation.mode} > "$f"
            fi
          done
        '';
      };
    }
    else {};
}
