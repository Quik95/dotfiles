{pkgs, ...}: let
  wifiManagerSync = pkgs.writeShellScript "wifi-manager-sync.sh" ''
    #!/usr/bin/env bash
    set -euo pipefail

    has_ethernet_connection() {
      shopt -s nullglob
      for iface in /sys/class/net/en* /sys/class/net/eth*; do
        if [ -e "$iface/carrier" ]; then
          carrier=$(cat "$iface/carrier" 2>/dev/null || echo "0")
          if [ "$carrier" = "1" ]; then
            shopt -u nullglob
            return 0
          fi
        fi
      done
      shopt -u nullglob
      return 1
    }

    get_wifi_state() {
      ${pkgs.networkmanager}/bin/nmcli radio wifi
    }

    desired_wifi_state() {
      if has_ethernet_connection; then
        echo "disabled"
      else
        echo "enabled"
      fi
    }

    sync_wifi_state() {
      local desired=$(desired_wifi_state)
      local current=$(get_wifi_state)

      if [ "$desired" = "disabled" ] && [ "$current" = "enabled" ]; then
        echo "Ethernet connected → disabling WiFi"
        ${pkgs.networkmanager}/bin/nmcli radio wifi off
      elif [ "$desired" = "enabled" ] && [ "$current" = "disabled" ]; then
        echo "No ethernet → enabling WiFi"
        ${pkgs.networkmanager}/bin/nmcli radio wifi on
      else
        echo "WiFi state already correct ($([ "$current" = "enabled" ] && echo "on" || echo "off"))"
      fi
    }

    sync_wifi_state
  '';
in {
  systemd.services.wifi-manager-sync = {
    description = "Synchronize WiFi state based on ethernet connectivity";
    after = ["network.target" "NetworkManager.service" "sys-subsystem-net-devices.device"];
    wants = ["network.target"];
    requires = ["NetworkManager.service"];
    bindsTo = ["NetworkManager.service"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${wifiManagerSync}";
      RemainAfterExit = false;
    };
  };

  systemd.timers.wifi-manager-sync = {
    description = "Debounce timer for WiFi state sync";
    timerConfig = {
      OnActiveSec = "3s";
      AccuracySec = "1s";
    };
  };

  systemd.services.wifi-manager-resume = {
    description = "Sync WiFi state after system resume";
    after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];

    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart wifi-manager-sync.timer";
    };
  };

  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "wifi-manager-dispatcher" ''
        ${pkgs.systemd}/bin/systemctl restart wifi-manager-sync.timer
      '';
      type = "basic";
    }
  ];
}
