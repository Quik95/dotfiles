{lib, ...}: {
  options.nixfiles.modem-manager.enable = lib.mkEnableOption "ModemManager for LTE/5G modem support";
}
