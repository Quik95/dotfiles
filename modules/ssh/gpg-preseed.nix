{
  pkgs,
  config,
  lib,
  hostname,
  ...
}:
lib.mkIf (hostname == "sebastian-laptop-legion") {
  services.gpg-agent.extraConfig = "allow-preset-passphrase";

  sops.secrets = {
    master-gpg-passphrase = {
      sopsFile = ../../home-manager/secrets/gpg-passphrases.yaml;
      key = "master";
    };
    gitlab-cs-put-gpg-passphrase = {
      sopsFile = ../../home-manager/secrets/gpg-passphrases.yaml;
      key = "gitlab-cs-put";
    };
  };

  systemd.user.services.gpg-preset-passphrase = {
    Unit.Description = "Preset GPG key passphrases at login";
    Service = {
      Type = "oneshot";
      ExecStart = "${import ./unlock-gpg-keys.nix {inherit pkgs config;}}";
      RemainAfterExit = true;
    };
    Install.WantedBy = ["graphical-session.target"];
  };
}
