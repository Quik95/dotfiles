{
  lib,
  pkgs,
  ...
}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";
in
  lib.mkIf isPlasma {
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.packagekit.enable = false;
    environment.plasma6.excludePackages = [pkgs.kdePackages.discover];

    # ksystemstats counts a client's repeated subscribe of one sensor twice but its single
    # unsubscribe once, so the sensor stays subscribed after the client is done. libksysguard
    # subscribes once per Sensor object; two SysPeek widgets probing gpu/gpu0 leave the NVIDIA
    # sensors subscribed, keeping `nvidia-smi dmon` running and the dGPU out of D3cold.
    nixpkgs.overlays = [
      (_: prev: {
        kdePackages = prev.kdePackages.overrideScope (_: kprev: {
          ksystemstats = kprev.ksystemstats.overrideAttrs (old: {
            patches = (old.patches or []) ++ [./patches/ksystemstats-refcount-client-subscriptions.patch];
          });

          # The greeter closes its views on LoginSucceeded and quits with the last window, so its
          # kwin_wayland is torn down while sddm-helper switches to the session VT. When VT_ACTIVATE
          # lands in that teardown, VT_WAITACTIVE hangs until waitForStarted() gives up after 30 s
          # ("Session started false"); 60 s later sddm kills the helper and starts a second greeter
          # next to the running session (sddm#1919, sddm#2129). Upstream da0b64d keeps the greeter
          # alive until the session has started; it is unreleased in 0.21.0.
          sddm = kprev.sddm.override {
            sddm-unwrapped = kprev.sddm.unwrapped.overrideAttrs (old: {
              patches =
                (old.patches or [])
                ++ [
                  (lib.warnIf (old.version != "0.21.0") ''
                      sddm ${old.version} may already include da0b64d ("greeter: Don't quit when the last window closes"):
                      drop the sddm patch in modules/wm/plasma/nixos.nix if it does.
                    ''
                    ./patches/sddm-greeter-dont-quit-on-last-window.patch)
                ];
            });
          };
        });
      })
    ];

    # baloo_file_extractor is a QGuiApplication and aborts without a display. kde-baloo.service
    # starts alongside kwin_wayland, before WAYLAND_DISPLAY/DISPLAY reach the systemd user
    # environment, so every extractor it forks crashes until the service restarts. Upstream
    # baloo commits 096b0d3f and a5431882 add this ordering after 6.31.0.
    # The upstream unit ships via environment.systemPackages, not systemd.packages, so NixOS
    # would otherwise generate a full replacement unit without ExecStart.
    systemd.user.services.kde-baloo = {
      overrideStrategy = "asDropin";
      after = lib.warnIf (lib.versionAtLeast pkgs.kdePackages.baloo.version "6.32") ''
        baloo ${pkgs.kdePackages.baloo.version} orders kde-baloo.service after the graphical session:
        remove the kde-baloo ordering override in modules/wm/plasma/nixos.nix.
      '' ["plasma-workspace.target" "graphical-session.target"];
    };

    programs.dconf.enable = true;

    # Installs kdeconnect-kde and opens TCP/UDP 1714-1764 for the protocol.
    programs.kdeconnect.enable = true;

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
      pkgs.kdePackages.kio-snapshot
    ];
    environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";
  }
