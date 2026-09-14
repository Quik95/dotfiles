{...}: {
  sops = {
    defaultSopsFile = ../../../home-manager/secrets/wifi-plus-rpB8.env;
    # System-level key (root-owned); HM uses a separate user-level key
    # at $XDG_CONFIG_HOME/sops/age/keys.txt (see modules/security/sops/home.nix)
    age.keyFile = "/var/lib/sops-nix/key.txt";

    secrets = {
      wifi-plus-rpB8 = {
        format = "dotenv";
        sopsFile = ../../../home-manager/secrets/wifi-plus-rpB8.env;
        mode = "0400";
      };
    };
  };
}
