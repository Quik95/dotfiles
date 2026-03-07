{
  config,
  pkgs,
  ...
}: let
  envycontrol = pkgs.python3Packages.buildPythonApplication {
    pname = "envycontrol";
    version = "3.5.2";
    pyproject = true;
    build-system = [pkgs.python3Packages.setuptools];
    dependencies = [pkgs.pciutils];
    src = pkgs.fetchFromGitHub {
      owner = "bayasdev";
      repo = "envycontrol";
      tag = "v3.5.2";
      hash = "sha256-FZMkYHUAA3keV7OSqzEIu0k1rdgDS0VP3nPBLBzbaeM=";
    };
  };
in {
  # RTX 5060 Mobile (Blackwell GB206M) + Intel Alder Lake-S hybrid graphics

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # Wymagane dla architektur Blackwell (GB***) i nowszych
    open = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;

    # GUI do konfiguracji GPU
    nvidiaSettings = true;

    # Zarządzanie energią dla PRIME offload
    powerManagement.enable = true;
    # RTD3: wyłącza dGPU gdy nieużywane (Turing+, działa z offload mode)
    powerManagement.finegrained = true;

    # Balansowanie mocy między CPU a GPU (laptopy z obsługą Dynamic Boost)
    dynamicBoost.enable = true;

    # PRIME offload: iGPU jako primary display, NVIDIA na żądanie
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      # Intel: 00:02.0
      intelBusId = "PCI:0:2:0";
      # NVIDIA: 01:00.0
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  environment.systemPackages = [envycontrol];
}
