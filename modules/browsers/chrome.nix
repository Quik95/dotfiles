{
  pkgs,
  lib,
  hostname,
  ...
}: let
  isLoq = hostname == "sebastian-laptop-legion";
  features =
    [
      "UseOzonePlatform"
      "TouchGestures"
      "TouchpadOverscrollHistoryNavigation"
      "AcceleratedVideoDecodeLinuxZeroCopyGL"
      "AcceleratedVideoEncoder"
      "VaapiIgnoreDriverChecks"
      "UseMultiPlaneFormatForHardwareVideo"
    ]
    ++ lib.optionals (!isLoq) [
      "Vulkan"
      "VulkanFromANGLE"
      "DefaultANGLEVulkan"
    ];

  chromeWrapped = pkgs.google-chrome.override {
    commandLineArgs = lib.concatStringsSep " " ([
        "--gtk-version=4"
        "--ignore-gpu-blocklist"
        "--enable-features=${lib.concatStringsSep "," features}"
        "--disable-features=GlobalShortcutsPortal"
        "--ozone-platform=wayland"
        "--ozone-platform-hint=auto"
        "--enable-gpu-rasterization"
        "--enable-experimental-web-platform-features"
        "--use-gl=angle"
      ]
      ++ lib.optionals (!isLoq) ["--use-angle=vulkan"]);
  };
in {
  home.packages = [chromeWrapped];
}
