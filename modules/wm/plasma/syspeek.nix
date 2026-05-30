{
  lib,
  pkgs,
  hostname,
  ...
}: let
  sysPeek = pkgs.stdenvNoCC.mkDerivation {
    pname = "syspeek";
    version = "1.3.0";

    src = pkgs.fetchFromGitHub {
      owner = "prassamin";
      repo = "SysPeek";
      rev = "v2.0.0";
      hash = "sha256-slpgxrz2O/Spgzv4SuI87vNkC7kpmqorTzqBFpGyImQ=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/plasma/plasmoids/com.pras.syspeek"
      cp -r ./* "$out/share/plasma/plasmoids/com.pras.syspeek/"
      runHook postInstall
    '';
  };
in {
  config = lib.mkIf (hostname == "sebastian-laptop-legion") {
    home.packages = [sysPeek];
  };
}
