{...}: {
  sops = {
    defaultSopsFile = ../../../home-manager/secrets/eduroam-certificate.bin;
    # System-level key (root-owned); HM uses a separate user-level key
    # at $XDG_CONFIG_HOME/sops/age/keys.txt (see modules/security/sops/home.nix)
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      eduroam-certificate = {
        format = "binary";
        sopsFile = ../../../home-manager/secrets/eduroam-certificate.bin;
        mode = "0400";
        owner = "wpa_supplicant";
      };

      eduroam-credentials = {
        format = "dotenv";
        sopsFile = ../../../home-manager/secrets/eduroam-credentials.env;
        mode = "0400";
      };

      tryhackme-openvpn = {
        format = "binary";
        sopsFile = ../../../home-manager/secrets/tryhackme-openvpn.bin;
        mode = "0400";
      };
    };
  };
}
