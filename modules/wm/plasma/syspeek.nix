{
  lib,
  pkgs,
  inputs,
  hostname,
  ...
}: let
  sysPeek = pkgs.stdenvNoCC.mkDerivation {
    pname = "syspeek";
    version = (builtins.fromJSON (builtins.readFile "${inputs.syspeek}/metadata.json")).KPlugin.Version;

    src = inputs.syspeek;

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
