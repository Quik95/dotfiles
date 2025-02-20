{config, ...}: {
  sops = {
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";
    secrets = {
      eduroam-certificate = {
        format = "binary";
        sopsFile = ../secrets/eduroam-certificate.bin;
        path = "${config.xdg.configHome}/certs/eduroam.p12";
      };

      gitlab-public-key = {
        sopsFile = ../secrets/gitlab-ssh-key.yaml;
        path = "${config.home.homeDirectory}/.ssh/gitlab_key.pub";
      };

      gitlab-private-key = {
        sopsFile = ../secrets/gitlab-ssh-key.yaml;
        path = "${config.home.homeDirectory}/.ssh/gitlab_key";
      };

      github-public-key = {
        sopsFile = ../secrets/github-ssh-key.yaml;
        path = "${config.home.homeDirectory}/.ssh/github_key.pub";
      };

      github-private-key = {
        sopsFile = ../secrets/github-ssh-key.yaml;
        path = "${config.home.homeDirectory}/.ssh/github_key";
      };

      master-public-gpg-key = {
        sopsFile = ../secrets/master-gpg-key.yaml;
        path = "${config.home.homeDirectory}/.gnupg/master-public-key.asc";
      };

      master-private-gpg-key = {
        sopsFile = ../secrets/master-gpg-key.yaml;
        path = "${config.home.homeDirectory}/.gnupg/master-private-key.asc";
      };
    };
  };
}
