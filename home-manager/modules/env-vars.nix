{
  pkgs,
  lib,
  config,
  ...
}: let
  env = import ../../shared/env.nix;
  envVars = [
    "CONTEXT7_API_KEY"
    "CODEX_ZAI_API_KEY"
  ];
in {
  home.sessionVariables = {
    BROWSER = env.browser;
    VISUAL = env.visual;
    EDITOR = env.editor;
    PAGER = env.pager;
    TERMINAL = env.terminal;
    NH_FLAKE = "${config.home.homeDirectory}/Documents/dotfiles";

    NIXOS_OZONE_WL = 1;
    NIXPKGS_ALLOW_UNFREE = 1;

    # xdg-ninja
    HISTFILE = "${config.xdg.stateHome}/bash/history";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    DOTNET_CLI_HOME = "${config.xdg.dataHome}/dotnet";
    NUGET_PACKAGES = "${config.xdg.cacheHome}/NuGetPackages";
    GNUPGHOME = config.custom.gpg.homedirLocation;
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    NPM_CONFIG_INIT_MODULE = "${config.xdg.configHome}/npm/config/npm-init.js";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_TMP = "/run/user/1000/npm"; # HACK or $XDG_RUNTIME_DIR
    OMNISHARPHOME = "${config.xdg.configHome}/omnisharp";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
  };

  systemd.user.services.env-secrets-loader = {
    Unit = {
      Description = "Load environment variables from sops";
      Before = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
    };

    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      EnvironmentFile = config.sops.secrets.env-secrets.path;

      ExecStart = "${pkgs.systemd}/bin/systemctl --user import-environment ${lib.concatStringsSep " " envVars}";
    };

    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };
}
