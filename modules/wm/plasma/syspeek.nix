{
  lib,
  pkgs,
  inputs,
  ...
}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";
  sysPeek = pkgs.stdenvNoCC.mkDerivation {
    pname = "syspeek";
    version = (builtins.fromJSON (builtins.readFile "${inputs.syspeek}/metadata.json")).KPlugin.Version;

    src = inputs.syspeek;

    # libksysguard only unsubscribes a sensor when it is disabled or destroyed, never when
    # its sensorId changes. Upstream's GPU probes (and the always-instantiated settings
    # window's copies) therefore keep gpu/gpu0 subscribed, which on this host is the NVIDIA
    # dGPU: `nvidia-smi dmon` keeps running and the dGPU never reaches D3cold.
    patches = [./patches/syspeek-release-gpu-sensors.patch];

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
