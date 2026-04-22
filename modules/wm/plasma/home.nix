{
  lib,
  hostname,
  ...
}: {
  imports = [
    ./appearance.nix
    ./behavior.nix
    ./panel.nix
    ./syspeek.nix
  ];

  config = lib.mkIf (hostname == "sebastian-laptop-legion") {
    programs.plasma = {
      enable = true;
      session.sessionRestore.restoreOpenApplicationsOnLogin = "startWithEmptySession";
    };
  };
}
