{pkgs, ...}: let
  wifiManagerSync = pkgs.substituteAll {
    src = ./wifi-manager-sync.sh;
    nmcli = "${pkgs.networkmanager}/bin/nmcli";
  };
in {
  # Declarative WiFi management service
  # Enforces: ethernet connected → WiFi off, ethernet disconnected → WiFi on
  systemd.services.wifi-manager-sync = {
    description = "Synchronize WiFi state based on ethernet connectivity";
    after = [ "network.target" "NetworkManager.service" ];
    wants = [ "network.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${wifiManagerSync}";
      RemainAfterExit = false;
    };
  };
  
  # Trigger sync after resume from suspend
  systemd.services.wifi-manager-resume = {
    description = "Sync WiFi state after system resume";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl start wifi-manager-sync.service";
    };
  };
  
  # Also use NetworkManager dispatcher as a trigger (more reliable for connection events)
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "wifi-manager-dispatcher" ''
        # Trigger sync on any network event
        ${pkgs.systemd}/bin/systemctl start wifi-manager-sync.service
      '';
      type = "basic";
    }
  ];
}
