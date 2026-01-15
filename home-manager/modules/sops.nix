{
  config,
  ...
}: let
  gpgHome = config.custom.gpg.homedirLocation;
in {
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    secrets = {
      identity-public-key = {
        sopsFile = ../secrets/id_ed25519.yaml;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };

      identity-private-key = {
        sopsFile = ../secrets/id_ed25519.yaml;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };

      gitlab-cs-put-gpg-public-key = {
        sopsFile = ../secrets/gitlab-cs-put-gpg-key.yaml;
        path = "${gpgHome}/gitlab-cs-put-public-key.asc";
      };

      gitlab-cs-put-gpg-private-key = {
        sopsFile = ../secrets/gitlab-cs-put-gpg-key.yaml;
        path = "${gpgHome}/gitlab-cs-put-private-key.asc";
      };

      master-public-gpg-key = {
        sopsFile = ../secrets/master-gpg-key.yaml;
        path = "${gpgHome}/master-public-key.asc";
      };

      master-private-gpg-key = {
        sopsFile = ../secrets/master-gpg-key.yaml;
        path = "${gpgHome}/master-private-key.asc";
      };
    };
  };
}
