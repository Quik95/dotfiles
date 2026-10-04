{config, ...}: {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.secrets.wifi-plus-rpB8.path
      config.sops.secrets.wifi-tcl-2pt7.path
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

    profiles.tcl-2pt7 = {
      connection = {
        id = "TCL-2PT7";
        uuid = "0caa025f-7661-4e70-ab74-10f7117d162b";
        type = "wifi";
        interface-name = "wlp4s0";
      };
      wifi = {
        mode = "infrastructure";
        ssid = "TCL-2PT7";
      };
      wifi-security = {
        key-mgmt = "wpa-psk";
        auth-alg = "open";
        psk = "$WIFI_TCL_2PT7_PASSWORD";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };
}
