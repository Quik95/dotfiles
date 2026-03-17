{lib, ...}: {
  specialisation = {
    # Odpowiednik envycontrol -s hybrid
    # dGPU śpi (RTD3), budzi się przez `nvidia-offload <cmd>`
    hybrid.configuration = {
      system.nixos.tags = ["hybrid"];

      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = lib.mkForce true;
      hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce true;

      hardware.nvidia.powerManagement.enable = lib.mkForce true;
      hardware.nvidia.powerManagement.finegrained = lib.mkForce true;

      hardware.nvidia.nvidiaPersistenced = lib.mkForce false;
    };

    # Odpowiednik envycontrol -s integrated
    # dGPU całkowicie zablokowany, tylko iGPU
    integrated.configuration = {
      system.nixos.tags = ["integrated"];

      services.xserver.videoDrivers = lib.mkForce ["modesetting"];

      boot.blacklistedKernelModules = [
        "nvidia"
        "nvidia_uvm"
        "nvidia_drm"
        "nvidia_modeset"
        "nouveau"
      ];

      hardware.nvidia.nvidiaPersistenced = lib.mkForce false;
    };
  };
}
