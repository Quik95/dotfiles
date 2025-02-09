# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  imports = [
    ./browsers/default.nix
    ./multimedia/default.nix
    ./terminal/default.nix
    ./wm/gnome/default.nix
    ./ide/default.nix

    ./default-apps.nix
    ./dropbox.nix
    ./env-vars.nix
    ./flatpak.nix
    ./misc.nix
  ];
}
