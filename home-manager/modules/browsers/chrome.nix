{config, lib, ...}:
let
  flags = ''
    --gtk-version=4
    --ignore-gpu-blocklist
    --enable-features=UseOzonePlatform,TouchGestures,TouchpadOverscrollHistoryNavigation
    --disable-features=GlobalShortcutsPortal
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-experimental-web-platform-features
    --ozone-platform-hint=auto
    '';
in {
  # We have to do this that way, because chrome doesn't have access to files in the nix store
  home.activation.createChromeFlags = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p "${config.home.homeDirectory}/.var/app/com.google.Chrome/config"
    echo "${flags}" > ${config.home.homeDirectory}/.var/app/com.google.Chrome/config/chrome-flags.conf
  '';
}
