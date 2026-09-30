{lib, ...}: {
  specialisation = {
    # Equivalent to envycontrol -s nvidia
    # NVIDIA renders everything, best for gaming / GPU-bound workloads.
    sync.configuration = {
      system.nixos.tags = ["sync"];

      hardware.nvidia.prime.offload.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;
      hardware.nvidia.prime.sync.enable = lib.mkForce true;

      hardware.nvidia.powerManagement.finegrained = lib.mkForce false;

      hardware.nvidia.nvidiaPersistenced = lib.mkForce true;
    };

    # Equivalent to envycontrol -s integrated
    # dGPU fully blocked, iGPU only
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

      hardware.nvidia.prime.offload.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce false;
      hardware.nvidia.dynamicBoost.enable = lib.mkForce false;
      hardware.nvidia.nvidiaPersistenced = lib.mkForce false;
    };
  };
}
