{
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  dropboxPath = "${config.home.homeDirectory}/Dropbox";
in {
  home.activation.setMaestralDropboxDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.maestral}/bin/maestral config set path ${dropboxPath}
  '';

  systemd.user.services.maestral = {
    Unit = {
      Description = "Maestral daemon";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
    Service = {
      ExecStart = "${pkgs.maestral}/bin/maestral start -f";
      ExecStop = "${pkgs.maestral}/bin/maestral stop";
      Restart = "on-failure";
      Nice = 10;
    };
  };
}
