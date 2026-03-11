{...}: {
  sops = {
    defaultSopsFile = ../../home-manager/secrets/eduroam-certificate.bin;
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      eduroam-certificate = {
        format = "binary";
        sopsFile = ../../home-manager/secrets/eduroam-certificate.bin;
        mode = "0400";
        owner = "wpa_supplicant";
      };

      eduroam-credentials = {
        format = "dotenv";
        sopsFile = ../../home-manager/secrets/eduroam-credentials.env;
        mode = "0400";
      };

      tryhackme-openvpn = {
        format = "binary";
        sopsFile = ../../home-manager/secrets/tryhackme-openvpn.bin;
        mode = "0400";
      };
    };
  };
}
