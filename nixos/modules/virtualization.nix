{pkgs, ...} :{
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";

    podman = {
      enable = true;
      dockerCompat = true;
      autoPrune.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  environment.systemPackages = with pkgs; [
    podman-compose
  ];
}
