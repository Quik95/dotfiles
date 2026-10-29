{
  config,
  lib,
  pkgs,
  ...
}: let
  # Ghostty 1.4.0 renamed/reworked options and fixed the systemd 262 readiness race.
  # Once nixpkgs ships it, drop `legacy` and keep only the 1.4 branches.
  legacy = lib.versionOlder config.programs.ghostty.package.version "1.4.0";
in {
  warnings = lib.optional (!legacy) "ghostty.nix: Ghostty is now >= 1.4.0; remove the `legacy` version guards and the notify-race drop-in.";

  # Ghostty <= 1.3.1 sends READY=1 before installing its SIGUSR2 handler; systemd >= 262
  # then refuses the Type=notify-reload unit, so the first D-Bus launch fails.
  # Fixed upstream in https://github.com/ghostty-org/ghostty/pull/14399 (Ghostty 1.4.0).
  xdg.configFile."systemd/user/app-com.mitchellh.ghostty.service.d/notify-race.conf" = lib.mkIf legacy {
    text = ''
      [Service]
      Type=dbus
      ExecReload=${pkgs.coreutils}/bin/kill -USR2 $MAINPID
    '';
  };

  # Ghostty 1.4's `+ssh` installs terminfo on the remote and forwards TERM_PROGRAM/COLORTERM.
  # Only wrap inside Ghostty; other terminals (kitty) keep plain ssh.
  programs.fish.functions.ssh = lib.mkIf (!legacy) {
    wraps = "ssh";
    body = ''
      if test "$TERM_PROGRAM" = ghostty
        ghostty +ssh -- $argv
      else
        command ssh $argv
      end
    '';
  };

  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    installBatSyntax = true;
    systemd.enable = true;
    settings =
      {
        app-notifications = "no-clipboard-copy,config-reload";
        clipboard-trim-trailing-spaces = true;
        confirm-close-surface = false;
      }
      // (
        if legacy
        then {
          copy-on-select = false;
          # 1.3 has no unlimited scrollback; a huge byte limit is lazily allocated.
          scrollback-limit = "9999999999999999999";
        }
        else {
          copy-on-select = "none";
          scrollback-limit-bytes = "unlimited";
        }
      )
      // {
        fullscreen = false;
        keybind = "ctrl+backspace=text:\\x17";
        link-previews = true;
        link-url = true;
        linux-cgroup = "always";
        maximize = true;
        notify-on-command-finish = "unfocused";
        notify-on-command-finish-after = "30s";
        quit-after-last-window-closed = false;
        resize-overlay = "always";
        selection-clear-on-copy = true;
        unfocused-split-opacity = 0.8;
        window-decoration = true;
        window-inherit-working-directory = true;
        window-padding-balance = true;
        window-save-state = "always";
        window-subtitle = "working-directory";
        window-theme = "ghostty";
      };
  };
}
