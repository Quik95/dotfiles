{
  config,
  lib,
  ...
}: {
  options.dotfiles.i2c.enable = lib.mkEnableOption "I2C support";

  config = lib.mkIf config.dotfiles.i2c.enable {
    hardware.i2c.enable = true;
  };
}
