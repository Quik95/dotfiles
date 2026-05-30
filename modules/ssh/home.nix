{
  pkgs,
  config,
  lib,
  hostname,
  ...
}: {
  imports = [
    ./gpg-preseed.nix
  ];

  options = {
    custom.gpg.homedirLocation = lib.mkOption {
      type = lib.types.path;
      default = "${config.xdg.dataHome}/gnupg";
      description = "The location of the GnuPG home directory.";
    };
  };

  config = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings."*" = {
        ForwardAgent = false;
        AddKeysToAgent = "yes";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "${config.home.homeDirectory}/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };
    };

    programs.gpg = {
      enable = true;
      homedir = config.custom.gpg.homedirLocation;
    };

    services.gpg-agent = {
      enable = true;
      enableFishIntegration = true;
      enableSshSupport = hostname != "sebastian-laptop-legion";
      defaultCacheTtl = 28800;
      maxCacheTtl = 28800;
      pinentry.package =
        if hostname == "sebastian-laptop-legion"
        then pkgs.pinentry-qt
        else pkgs.pinentry-gnome3;
    };

    home.activation.importGpgKeys = lib.hm.dag.entryAfter ["writeBoundary"] ''
      for key in \
        ${config.sops.secrets.master-public-gpg-key.path} \
        ${config.sops.secrets.master-private-gpg-key.path} \
        ${config.sops.secrets.gitlab-cs-put-gpg-public-key.path} \
        ${config.sops.secrets.gitlab-cs-put-gpg-private-key.path}; do
        if [ -f "$key" ]; then
          run ${pkgs.gnupg}/bin/gpg --homedir ${config.programs.gpg.homedir} --import "$key"
        fi
      done
    '';
  };
}
