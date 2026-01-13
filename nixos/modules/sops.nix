{config, ...}: let
  homeDir = config.users.users.sebastian.home;
  certPath = "/run/wpa_supplicant/eduroam.p12";
in {
  sops = {
    defaultSopsFile = ../../home-manager/secrets/eduroam-certificate.bin;
    age.keyFile = "${homeDir}/.config/sops/age/keys.txt";

    secrets.eduroam-certificate = {
      format = "binary";
      sopsFile = ../../home-manager/secrets/eduroam-certificate.bin;
      mode = "0400";
    };
  };

  # Copy eduroam certificate to wpa_supplicant runtime directory
  systemd.services.eduroam-cert-copy = {
    description = "Copy eduroam certificate for wpa_supplicant";
    wantedBy = ["multi-user.target"];
    before = ["wpa_supplicant.service" "NetworkManager.service"];
    after = ["sops-nix.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/wpa_supplicant
      install -m 0444 ${config.sops.secrets.eduroam-certificate.path} ${certPath}
    '';
  };
}
