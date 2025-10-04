{
  config,
  pkgs,
  ...
}: {
  # Enable common modules that are shared across all profiles
  myHomeManager = {
    # Terminal tools (enabled by default)
    terminal = {
      enable = true;
      shells.enable = true;
      shells.fish.enable = true;
      emulators.enable = true;
      emulators.ghostty.enable = true;
      git.enable = true;
      atuin.enable = true;
      bat.enable = true;
      btop.enable = true;
      eza.enable = true;
      starship.enable = true;
      powerlineGo.enable = true;
      yazi.enable = true;
      zoxide.enable = true;
    };

    # Browsers
    browsers = {
      enable = true;
      firefox.enable = true;
      chrome.enable = true;
    };

    # IDE and editors
    ide = {
      enable = true;
      nixvim.enable = true;
      helix.enable = true;
      vscode.enable = true;
      jetbrains.enable = true;
      zed.enable = true;
      direnv.enable = true;
    };

    # SDK tools
    sdk = {
      enable = true;
      rust.enable = true;
      c.enable = true;
    };

    # Multimedia
    multimedia = {
      enable = true;
      mpv.enable = true;
      ytDlp.enable = true;
      foliate.enable = true;
    };

    # System integration
    system = {
      defaultApps.enable = true;
      dropbox.enable = true;
      flatpak.enable = true;
      sops.enable = true;
      ssh.enable = true;
      stylix.enable = true;
    };
  };

  # Common packages that don't fit into specific modules
  home.packages = with pkgs; [
    fortune
    ffmpeg-full
    resources
    tokei
    maestral
    vdhcoapp
    fselect
    just
    mask
    mprocs
    kondo
    appimage-run
    litecli
    zed-editor
    gemini-cli
    devenv
    sops
  ];
}
