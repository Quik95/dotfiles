{pkgs, ...}: let
  iniFormat = pkgs.formats.ini {};
in {
  xdg.configFile."rsgain/presets/music.ini".source = iniFormat.generate "rsgain-music.ini" {
    Global = {
      TagMode = "i";
      Album = true;
      TargetLoudness = -18;
      TruePeak = true;
      ClipMode = "p";
      MaxPeakLevel = 0;
      PreserveMtimes = true;
    };
  };
}
