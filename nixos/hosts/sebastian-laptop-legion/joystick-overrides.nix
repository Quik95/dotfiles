{
  config,
  lib,
  pkgs,
  ...
}: let
  # nixpkgs signs out-of-tree modules via kmodigest only in `make modules_install`
  # (`cmd_sign` in kernel/common-flags.nix), and the module aggregator requires a
  # `<module>.ko.cer` per external module. xpad-noone installs its .ko by hand, so
  # it ships unsigned and breaks the `linux-*-modules` build. Sign it ourselves
  # until nixpkgs stops copying the .ko by hand or signs it, then warn that the
  # override can go.
  upstreamXpadNoone = config.boot.kernelPackages.xpad-noone;
  xpadNooneBuild = lib.concatStringsSep "\n" [
    (upstreamXpadNoone.installPhase or "")
    (upstreamXpadNoone.postInstall or "")
    (toString (upstreamXpadNoone.nativeBuildInputs or []))
  ];
  xpadNooneFixed =
    !(lib.hasInfix "install *.ko" xpadNooneBuild)
    || lib.hasInfix "kmodigest" xpadNooneBuild;
in {
  hardware.xone.enable = true;

  hardware.xpad-noone.enable =
    lib.warnIf xpadNooneFixed ''
      nixpkgs xpad-noone no longer installs its .ko unsigned by hand: remove the
      xpad-noone signing override in nixos/hosts/sebastian-laptop-legion/joystick-overrides.nix.
    ''
    xpadNooneFixed;
  boot.extraModulePackages = lib.optional (!xpadNooneFixed) (upstreamXpadNoone.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.buildPackages.kmodigest];
    postInstall =
      (old.postInstall or "")
      + ''
        for ko in "$out"/lib/modules/*/kernel/drivers/xpad-noone/*.ko; do
          kmodigest "$ko"
        done
      '';
  }));

  services.udev.packages = [pkgs.game-devices-udev-rules];

  # GameSir G7 SE (VID 3537) enumerates in a transient XUSB mode (PID 10a0)
  # on cold boot. Linux fails to read the configuration descriptor for this
  # mode (EPROTO -71), and the device falls back to a limited HID mode
  # (PID 1082) with no LED or rumble support.
  #
  # These USB quirks alter the enumeration timing so that when the 10a0 mode
  # fails, the device re-enumerates in GIP mode (PID 1073) instead of HID.
  # The xone driver then claims the GIP interface for full functionality.
  #
  # Quirk flags: g = DELAY_INIT, k = NO_LPM, n = DELAY_CTRL_MSG
  boot.kernelParams = ["usbcore.quirks=3537:10a0:gkn"];

  boot.blacklistedKernelModules = ["xpad"];
}
