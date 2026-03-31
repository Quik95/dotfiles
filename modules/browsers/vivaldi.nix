{
  pkgs,
  lib,
  ...
}: let
  features = [
    "UseOzonePlatform"
    "TouchGestures"
    "TouchpadOverscrollHistoryNavigation"
    "VaapiVideoDecoder"
    "AcceleratedVideoDecodeLinuxGL"
    "AcceleratedVideoDecodeLinuxZeroCopyGL"
    "AcceleratedVideoEncoder"
    "UseMultiPlaneFormatForHardwareVideo"
  ];

  vivaldiWrapped = pkgs.vivaldi.override {
    proprietaryCodecs = true;
    enableWidevine = true;
    commandLineArgs = lib.concatStringsSep " " [
      "--ozone-platform=wayland"
      "--ozone-platform-hint=auto"
      "--enable-wayland-ime"
      "--ignore-gpu-blocklist"
      "--enable-gpu-rasterization"
      "--enable-zero-copy"
      "--enable-features=${lib.concatStringsSep "," features}"
      "--disable-features=GlobalShortcutsPortal"
    ];
  };
in {
  home.packages = [vivaldiWrapped];
}
