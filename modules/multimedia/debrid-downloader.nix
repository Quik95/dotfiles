{
  pkgs,
  inputs,
  ...
}: let
  debrid-downloader = pkgs.stdenv.mkDerivation {
    pname = "debrid-downloader";
    version = "1.7.0";

    src = inputs.debrid-downloader;

    nativeBuildInputs = [pkgs.autoPatchelfHook pkgs.dpkg pkgs.makeWrapper];
    buildInputs = with pkgs; [
      alsa-lib
      glib
      gtk3
      libayatana-appindicator
      openssl
      webkitgtk_4_1
    ];

    unpackPhase = ''
      runHook preUnpack
      dpkg-deb -x "$src" .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r usr/* "$out/"
      runHook postInstall
    '';

    postFixup = ''
      wrapProgram "$out/bin/debriddownloader" \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [pkgs.libayatana-appindicator]}"
    '';

    meta = {
      description = "Desktop downloader for TorBox and other debrid services";
      homepage = "https://github.com/CasaVargas/DebridDownloader";
      platforms = ["x86_64-linux"];
      mainProgram = "debriddownloader";
    };
  };
in {
  home.packages = [debrid-downloader];
}
