{lib, ...}: {
  specialisation = {
    # Equivalent to envycontrol -s hybrid
    # dGPU sleeps (RTD3), wakes up via `nvidia-offload <cmd>`
    hybrid.configuration = {
      system.nixos.tags = ["hybrid"];

      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia.prime.offload.enable = lib.mkForce true;
      hardware.nvidia.prime.offload.enableOffloadCmd = lib.mkForce true;

      hardware.nvidia.powerManagement.enable = lib.mkForce true;
      hardware.nvidia.powerManagement.finegrained = lib.mkForce true;

      hardware.nvidia.nvidiaPersistenced = lib.mkForce false;
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

      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia.dynamicBoost.enable = lib.mkForce false;
      hardware.nvidia.nvidiaPersistenced = lib.mkForce false;
    };
  };
}
