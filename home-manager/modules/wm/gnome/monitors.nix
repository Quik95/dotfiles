{
  pkgs,
  lib,
  hostname,
  ...
}: let
  monitorScript = pkgs.writeShellApplication {
    name = "restore-monitors";
    runtimeInputs = [pkgs.coreutils pkgs.glib pkgs.gnome-monitor-config];
    text = builtins.readFile ./restore-monitors.sh;
  };
in
  lib.mkIf (hostname == "sebastian-laptop-hp") {
    home.packages = [pkgs.gnome-monitor-config pkgs.glib];

    systemd.user.services.gnome-monitor-restore = {
      Unit = {
        Description = "Restore GNOME monitor layout";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
        StartLimitIntervalSec = 5;
        StartLimitBurst = 1;
      };
      Service = {
        Type = "simple";
        ExecStart = "${monitorScript}/bin/restore-monitors";
        Restart = "always";
        RestartSec = 2;
        # Security hardening - service only needs D-Bus for GNOME
        CapabilityBoundingSet = "";
        PrivateNetwork = true; # no network access needed
        PrivateDevices = true; # no device access needed
        PrivateTmp = true; # no shared /tmp access needed
        ProtectClock = true; # doesn't write to system/hw clock
        ProtectSystem = "strict"; # doesn't write to system
        ProtectHome = "read-only"; # doesn't write to home
        ProtectKernelLogs = true; # doesn't read/write kernel logs
        ProtectKernelTunables = true; # doesn't modify kernel
        ProtectKernelModules = true; # doesn't load modules
        ProtectHostname = true; # doesn't change hostname
        ProtectControlGroups = true; # doesn't modify cgroups
        NoNewPrivileges = true; # doesn't escalate privileges
        ProtectProc = "invisible";
        ProcSubset = "pid";
        RestrictAddressFamilies = ["AF_UNIX"];
        RestrictRealtime = true; # doesn't need realtime
        RestrictSUIDSGID = true; # doesn't create SUID
        RestrictNamespaces = true; # doesn't create namespaces
        LockPersonality = true; # doesn't change ABI
        MemoryDenyWriteExecute = true; # doesn't need JIT
        SystemCallArchitectures = "native";
        UMask = "0077";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
    };
  }
