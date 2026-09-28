{
  lib,
  pkgs,
  inputs,
  ...
}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";

  # 1.0.0 misses /home/.snapshots with the @/@home layout; see the
  # kio-snapshot input in flake.nix. Once nixpkgs ships a newer release, use
  # it and warn that the override and the flake input can go.
  upstreamKioSnapshot = pkgs.kdePackages.kio-snapshot;
  kioSnapshotReleased = lib.versionOlder "1.0.0" upstreamKioSnapshot.version;
  kio-snapshot =
    lib.warnIf kioSnapshotReleased ''
      kdePackages.kio-snapshot ${upstreamKioSnapshot.version} is now in nixpkgs: remove the
      kio-snapshot override in modules/wm/plasma/nixos.nix and the kio-snapshot input in flake.nix.
    ''
    (
      if kioSnapshotReleased
      then upstreamKioSnapshot
      else
        upstreamKioSnapshot.overrideAttrs {
          version = "1.0.0-unstable-2026-09-28";
          src = inputs.kio-snapshot;
        }
    );
in
  lib.mkIf isPlasma {
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.packagekit.enable = false;
    environment.plasma6.excludePackages = [pkgs.kdePackages.discover];

    programs.dconf.enable = true;

    xdg.portal.enable = true;

    services.xserver.autoRepeatDelay = 200;
    services.xserver.autoRepeatInterval = 15;

    security.pam.services.sddm.kwallet.enable = true;
    security.pam.services.kde.kwallet.enable = true;
    security.pam.services.login.kwallet.enable = true;

    programs.ssh.startAgent = true;
    programs.ssh.enableAskPassword = true;
    programs.ssh.askPassword = lib.mkForce "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

    environment.systemPackages = [
      pkgs.kdePackages.ksshaskpass
      pkgs.kdePackages.plasma-keyboard
      kio-snapshot
    ];
    environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";
  }
