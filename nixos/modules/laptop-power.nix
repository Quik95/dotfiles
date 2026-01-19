{
  config,
  lib,
  pkgs,
  ...
}: {
  # Power management optimizations for laptop usage

  # Enable power management
  powerManagement = {
    enable = true;
  };

  # Enable power-profiles-daemon for GNOME integration
  # Provides power profile switching through GNOME Settings
  services.power-profiles-daemon.enable = true;

  # Additional kernel parameters for power saving
  boot.kernelParams = [
    # AMD power saving options
    "amd_pstate=active"
    # Enable power saving for audio
    "snd_hda_intel.power_save=1"
    # NMI watchdog can wake CPU unnecessarily
    "nmi_watchdog=0"
  ];

  # Enable fstrim for SSD maintenance (reduces wear and improves performance)
  services.fstrim.enable = true;

  # Install useful power management tools
  environment.systemPackages = with pkgs; [
    powertop
    acpi
    lm_sensors
  ];
}
