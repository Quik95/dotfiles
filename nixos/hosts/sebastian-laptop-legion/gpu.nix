{config, ...}: {
  # RTX 5050 Mobile (Blackwell) + AMD Ryzen 7 hybrid graphics

  services.xserver.videoDrivers = ["nvidia"];

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # Required for Blackwell (GB***) and newer architectures
    open = true;

    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;

    nvidiaSettings = false;

    # Save and restore VRAM across suspend/resume to prevent Xid 13
    # (shader corruption / missing textures after wake).
    powerManagement.enable = true;
    # RTD3: power the dGPU off (D3cold) while idle.
    powerManagement.finegrained = true;

    # Enable NVIDIA Dynamic Boost through nvidia-powerd.
    dynamicBoost.enable = true;

    nvidiaPersistenced = false;

    # PRIME offload: AMD iGPU composites, dGPU renders on demand
    # (`nvidia-offload <cmd>`). HDMI on the dGPU works via display offload.
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      # AMD iGPU: 65:00.0 (0x65 = 101 decimal)
      amdgpuBusId = "PCI:101:0:0";
      # NVIDIA: 01:00.0
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
