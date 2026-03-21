{lib, ...}: {
  options.nixfiles.i2c.enable = lib.mkEnableOption "I2C support";
}
