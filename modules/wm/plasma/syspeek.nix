{
  lib,
  pkgs,
  sources,
  ...
}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";
  sysPeek = pkgs.stdenvNoCC.mkDerivation {
    inherit (sources.syspeek) pname version src;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/plasma/plasmoids/com.pras.syspeek"
      cp -r ./* "$out/share/plasma/plasmoids/com.pras.syspeek/"
      runHook postInstall
    '';
  };
in {
  config = lib.mkIf isPlasma {
    home.packages = [sysPeek];
  };
}
