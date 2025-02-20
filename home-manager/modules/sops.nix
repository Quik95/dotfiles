{config, ...}: {
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    secrets = {
      eduroam-certificate = {
        format = "binary";
        sopsFile = ../secrets/eduroam-certificate.bin;
        path = "${config.xdg.configHome}/certs/eduroam.p12";
      };
    };
  };
}
