{
  pkgs,
  lib,
  ...
}: let
  vivaldiWrapped = pkgs.vivaldi.override {
    proprietaryCodecs = true;
    enableWidevine = true;
    commandLineArgs = lib.concatStringsSep " " [
      "--ozone-platform-hint=auto"
      "--enable-wayland-ime"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-features=VaapiVideoDecoder,AcceleratedVideoDecodeLinuxGL,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoEncoder,UseMultiPlaneFormatForHardwareVideo"
    ];
  };
in {
  home.packages = [vivaldiWrapped];
}
