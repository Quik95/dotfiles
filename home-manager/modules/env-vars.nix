{config, ...}: let
  env = import ../../shared/env.nix;
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
}
