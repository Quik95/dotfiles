{
  home.file."$HOME/.var/app/com.google.Chrome/config/chrome-flags.conf".text = ''
    --gtk-version=4
    --ignore-gpu-blocklist
    --enable-features=UseOzonePlatform,TouchGestures
    --ozone-platform=wayland
    --enable-gpu-rasterization
    --enable-experimental-web-platform-features
    --ozone-platform-hint=auto
    --enable-features=TouchpadOverscrollHistoryNavigation
    '';
}
