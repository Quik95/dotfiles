{config, ...}: let
  interfaceName = config.nixfiles.eduroam.interfaceName;
in {
  networking.networkmanager.ensureProfiles = {
    environmentFiles = [
      config.sops.secrets.eduroam-credentials.path
    ];

    profiles.eduroam = {
      connection = {
        id = "eduroam";
        type = "wifi";
        interface-name = interfaceName;
      };
      wifi = {
        mode = "infrastructure";
        ssid = "eduroam";
      };
      wifi-security = {
        key-mgmt = "wpa-eap";
      };
      "802-1x" = {
        eap = "tls;";
        identity = "$EDUROAM_IDENTITY";
        client-cert = "file://${config.sops.secrets.eduroam-certificate.path}";
        private-key = "file://${config.sops.secrets.eduroam-certificate.path}";
        private-key-password = "$EDUROAM_P12_PASSWORD";
      };
      ipv4.method = "auto";
      ipv6.method = "auto";
    };
  };

  # The wpa_supplicant service runs in a sandbox (chroot) where /run/secrets
  # is not visible. We need to explicitly bind-mount the certificate file
  # so the service can access it.
  systemd.services.wpa_supplicant.serviceConfig.BindReadOnlyPaths = [
    config.sops.secrets.eduroam-certificate.path
  ];
}
