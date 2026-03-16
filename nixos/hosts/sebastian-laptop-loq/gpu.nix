{
  config,
  pkgs,
  ...
}: {
  # RTX 5060 Mobile (Blackwell GB206M) + Intel Alder Lake-S hybrid graphics

  services.xserver.videoDrivers = ["nvidia"];
  # Mixed-refresh multi-monitor setups are more reliable on GNOME Wayland than X11.
  services.displayManager.gdm.wayland = true;

  hardware.graphics.enable = true;

  hardware.nvidia = {
    # Wymagane dla architektur Blackwell (GB***) i nowszych
    open = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;

    # GUI do konfiguracji GPU
    nvidiaSettings = true;

    # Priorytet: maksymalna płynność przy konfiguracji multi-monitor.
    # Utrzymujemy dGPU aktywne (kosztem baterii), bez agresywnego RTD3.
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Balansowanie mocy między CPU a GPU (laptopy z obsługą Dynamic Boost)
    dynamicBoost.enable = true;

    # Utrzymuj kontekst GPU aktywny dla niższych opóźnień wybudzania.
    nvidiaPersistenced = true;

    # PRIME sync: NVIDIA renderuje całość, iGPU obsługuje panel wbudowany.
    prime = {
      sync.enable = true;

      # Intel: 00:02.0
      intelBusId = "PCI:0:2:0";
      # NVIDIA: 01:00.0
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
