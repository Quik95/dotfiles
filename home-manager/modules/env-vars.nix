{
  config,
  options,
  ...
}: {
  home.sessionVariables = {
    BROWSER = "firefox";
    VISUAL = "zeditor";
    EDITOR = "nvim";
    PAGER = "bat";
    TERMINAL = "ghostty";
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
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${config.xdg.configHome}/java";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
    RUSTUP_HOME ="${config.xdg.dataHome}/rustup";
  };
}
