{config, ...}: let
  gpgHome = config.custom.gpg.homedirLocation;
in {
  sops = {
    # User-level key; NixOS system secrets use a separate root-owned key
    # at /var/lib/sops-nix/key.txt (see modules/security/sops/nixos.nix)
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    secrets = {
      identity-public-key = {
        sopsFile = ../../../home-manager/secrets/id_ed25519.yaml;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };

      identity-private-key = {
        sopsFile = ../../../home-manager/secrets/id_ed25519.yaml;
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };

      gitlab-cs-put-gpg-public-key = {
        sopsFile = ../../../home-manager/secrets/gitlab-cs-put-gpg-key.yaml;
        path = "${gpgHome}/gitlab-cs-put-public-key.asc";
      };

      gitlab-cs-put-gpg-private-key = {
        sopsFile = ../../../home-manager/secrets/gitlab-cs-put-gpg-key.yaml;
        path = "${gpgHome}/gitlab-cs-put-private-key.asc";
      };

      master-public-gpg-key = {
        sopsFile = ../../../home-manager/secrets/master-gpg-key.yaml;
        path = "${gpgHome}/master-public-key.asc";
      };

      master-private-gpg-key = {
        sopsFile = ../../../home-manager/secrets/master-gpg-key.yaml;
        path = "${gpgHome}/master-private-key.asc";
      };

      "CODEX_ZAI_API_KEY" = {
        sopsFile = ../../../home-manager/secrets/env-secrets.yaml;
        key = "CODEX_ZAI_API_KEY";
        format = "yaml";
      };

      "CONTEXT7_API_KEY" = {
        sopsFile = ../../../home-manager/secrets/env-secrets.yaml;
        key = "CONTEXT7_API_KEY";
        format = "yaml";
      };
    };
  };
}
