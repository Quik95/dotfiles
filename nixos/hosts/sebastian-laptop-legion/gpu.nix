{config, ...}: {
  # RTX 5050 Mobile (Blackwell) + AMD Ryzen 7 hybrid graphics

  services.xserver.videoDrivers = ["nvidia"];
  # Mixed-refresh multi-monitor setups are more reliable on GNOME Wayland than X11.
  services.displayManager.gdm.wayland = true;

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # Required for Blackwell (GB***) and newer architectures
    open = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;

    nvidiaSettings = true;

    # Prioritize smoothness for multi-monitor setups.
    # Keep dGPU active (at a battery cost), without aggressive RTD3.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Balance power between CPU and GPU (laptops with Dynamic Boost support)
    dynamicBoost.enable = true;

    # Keep GPU context active for lower wake latency.
    nvidiaPersistenced = true;


    # PRIME sync: NVIDIA renders, iGPU drives the internal panel.
    prime = {
      sync.enable = true;

      # AMD iGPU: 65:00.0 (0x65 = 101 decimal)
      amdgpuBusId = "PCI:101:0:0";
      # NVIDIA: 01:00.0
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
