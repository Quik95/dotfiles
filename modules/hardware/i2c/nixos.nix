{
  config,
  lib,
  ...
}:
lib.mkIf config.nixfiles.i2c.enable {
  hardware.i2c.enable = true;
}
