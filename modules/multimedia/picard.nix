{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: let
  settingsPython = pkgs.python3.withPackages (ps: [ps.pyqt6]);
  # Qt Multimedia resolves PipeWire dynamically for the audio preview backend.
  picard = pkgs.picard.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./picard-request-timeout.patch];
    makeWrapperArgs =
      (old.makeWrapperArgs or [])
      ++ ["--prefix" "LD_LIBRARY_PATH" ":" (lib.makeLibraryPath [pkgs.pipewire])];
  });
in {
  home.packages = [
    picard
    pkgs.aubio
    pkgs.ffmpeg-full
  ];

  xdg.dataFile = {
    "MusicBrainz/Picard/plugins3/fanarttv".source = inputs."picard-plugin-fanarttv";
    "MusicBrainz/Picard/plugins3/lrclib".source = inputs."picard-plugin-lrclib";
    "MusicBrainz/Picard/plugins3/bpm".source = ./picard-plugins/bpm;
    "MusicBrainz/Picard/plugins3/deezerart".source = ./picard-plugins/deezerart;
  };

  # Keep Picard's settings writable; update only audited keys and retain
  # credentials, profiles and window state in the existing Qt INI.
  home.activation.picardSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
    run ${settingsPython}/bin/python ${./configure-picard.py} \
      ${lib.escapeShellArg "${config.xdg.configHome}/MusicBrainz/Picard.ini"} \
      ${lib.escapeShellArg "${config.xdg.stateHome}/picard"} \
      ${lib.escapeShellArg "${config.home.homeDirectory}/Music/some_shitty_music"} \
      ${lib.escapeShellArg "${pkgs.chromaprint}/bin/fpcalc"}
  '';
}
