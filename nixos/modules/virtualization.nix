{pkgs, ...} :{
  virtualisation = {
    containers.enable = true;
    oci-containers.backend = "podman";

    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      autoPrune.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  services.k3s = {
    enable = true;
    role = "server";
  };

  environment.systemPackages = with pkgs; [
    podman-compose
    k3d
  ];
}
