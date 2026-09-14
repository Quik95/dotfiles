{config, ...}: {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.secrets.wifi-plus-rpB8.path
    ];

    profiles.plus-rpB8 = {
      connection = {
        id = "PLUS-rpB8";
        type = "wifi";
        interface-name = "wlp4s0";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "PLUS-rpB8";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        psk = "$WIFI_PASSWORD";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
