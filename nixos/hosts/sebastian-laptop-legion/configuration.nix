{
  config,
  lib,
  pkgs,
  ...
}: let
  lenovoConservation = {
    enable = true;
    mode = 1; # 1 = conservation on (~80%), 0 = off (charge to 100%)
  };
  useUpowerChargeThreshold = config.services.desktopManager.gnome.enable;
in {
  imports = [
    ./hardware-configuration.nix
    ./gpu.nix
    ./gpu-specialisations.nix
    ../../common.nix
  ];

  fileSystems."/".options = ["compress=zstd"];
  fileSystems."/home".options = ["compress=zstd"];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.limine = {
    enable = true;
    efiSupport = true;
    extraEntries = ''
      /CachyOS
        protocol: efi_chainload
        image_path: guid(50dc3c4d-786c-4282-8bc1-3c0bc12ebae7):/EFI/limine/limine_x64.efi

      /Windows
        protocol: efi_chainload
        image_path: guid(37f7fac0-c32a-424d-b7b9-7b9b9581b575):/EFI/Microsoft/Boot/bootmgfw.efi
    '';
  };

  networking.hostName = "sebastian-laptop-legion";
  networking.networkmanager.ethernet.macAddress = "38:a7:46:3b:16:ed";
  dotfiles.eduroam.interfaceName = "wlp4s0";
  dotfiles.i2c.enable = true;
  dotfiles.passwordless-sudo.enable = false;

  boot.kernelParams = ["amd_pstate=active"];

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 100;
  };

  swapDevices = lib.mkForce [];

  boot.kernel.sysctl = {
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
    "vm.vfs_cache_pressure" = 125;
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
  };

  services.logind.settings.Login.HandleLidSwitch = "suspend";

  systemd.sleep.settings.Sleep = {
    AllowHibernation = "no";
    AllowSuspendThenHibernate = "no";
    SuspendState = "mem";
  };

  assertions = [
    {
      assertion = builtins.elem lenovoConservation.mode [0 1];
      message = "lenovoConservation.mode must be 0 or 1.";
    }
  ];

  # Under GNOME, prefer UPower D-Bus API for charge-threshold control.
  # Outside GNOME, fall back to Lenovo ideapad_acpi sysfs conservation mode.
  systemd.services =
    if lenovoConservation.enable
    then {
      lenovo-conservation-mode = {
        description = "Set Lenovo battery conservation mode";
        wantedBy = ["multi-user.target"];
        after =
          ["local-fs.target"]
          ++ lib.optionals useUpowerChargeThreshold ["upower.service"];
        wants = lib.optionals useUpowerChargeThreshold ["upower.service"];
        unitConfig =
          if useUpowerChargeThreshold
          then {
            ConditionPathExists = "/run/dbus/system_bus_socket";
          }
          else {
            ConditionPathExistsGlob = "/sys/bus/platform/drivers/ideapad_acpi/VPC2004:*/conservation_mode";
          };
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
          ReadWritePaths = lib.optionals (!useUpowerChargeThreshold) ["/sys/bus/platform/drivers/ideapad_acpi"];
        };
        script =
          if useUpowerChargeThreshold
          then ''
            enabled=${
              if lenovoConservation.mode == 1
              then "true"
              else "false"
            }

            for dev in /org/freedesktop/UPower/devices/battery_BAT0 /org/freedesktop/UPower/devices/battery_BAT1; do
              if ${pkgs.systemd}/bin/busctl --system --quiet get-property org.freedesktop.UPower "$dev" org.freedesktop.UPower.Device ChargeThresholdSupported >/dev/null 2>&1; then
                ${pkgs.systemd}/bin/busctl --system call org.freedesktop.UPower "$dev" org.freedesktop.UPower.Device EnableChargeThreshold b "$enabled"
              fi
            done
          ''
          else ''
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
