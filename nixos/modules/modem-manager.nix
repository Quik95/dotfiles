{
  config,
  lib,
  ...
}: {
  options.dotfiles.modem-manager.enable = lib.mkEnableOption "ModemManager for LTE/5G modem support";

  config = {
    networking.modemmanager.enable = config.dotfiles.modem-manager.enable;
  };
}
