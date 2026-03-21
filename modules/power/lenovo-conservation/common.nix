{lib, ...}: {
  options.nixfiles.power.lenovo-conservation = {
    enable = lib.mkEnableOption "Lenovo battery conservation mode service";

    mode = lib.mkOption {
      type = lib.types.enum [0 1];
      default = 1;
      example = 0;
      description = "Conservation mode value: 1 keeps charge near 80%, 0 disables conservation.";
    };
  };
}
