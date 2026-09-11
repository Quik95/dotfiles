# Which desktop environment the hosts run.
#
# Every desktop-specific module (modules/wm/*, plus the handful of modules that
# ship different applications or agents per desktop) gates on this value instead
# of on the hostname, so switching desktops is a one-line change here followed by
# a NixOS + Home Manager rebuild and a re-login.
#
# Supported values: "plasma", "gnome".
{
  desktop = "plasma";
}
