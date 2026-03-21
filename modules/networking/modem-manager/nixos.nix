{config, ...}: {
  networking.modemmanager.enable = config.nixfiles.modem-manager.enable;
}
