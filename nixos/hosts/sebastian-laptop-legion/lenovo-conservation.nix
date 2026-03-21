{
  config,
  lib,
  pkgs,
  ...
}: let
  mode = 1; # 1 = conservation on (~80%), 0 = off (charge to 100%)
  useUpowerChargeThreshold = config.services.desktopManager.gnome.enable;
in {
  assertions = [
    {
      assertion = builtins.elem mode [0 1];
      message = "lenovo conservation mode must be 0 or 1.";
    }
  ];

  systemd.services.lenovo-conservation-mode = {
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
          if mode == 1
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
            echo ${toString mode} > "$f"
          fi
        done
      '';
  };
}
