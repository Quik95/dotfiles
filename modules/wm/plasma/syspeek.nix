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
      rev = "v1.3.0";
      hash = "sha256-7QQnsDzkf7g3MZeU7Rc2SYh2iKCGUUhMEwS4qOvPvA0=";
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
