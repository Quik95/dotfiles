{pkgs, lib, ...}: let
  aubio-python312 = pkgs.python312Packages.buildPythonPackage {
    pname = "aubio";
    version = "0.4.9";
    format = "setuptools";

    src = pkgs.fetchurl {
      url = "https://aubio.org/pub/aubio-0.4.9.tar.bz2";
      sha256 = "1npks71ljc48w6858l9bq30kaf5nph8z0v61jkfb70xb9np850nl";
    };

    nativeBuildInputs = [pkgs.pkg-config];
    buildInputs = with pkgs; [aubio fftw libsndfile];
    propagatedBuildInputs = [pkgs.python312Packages.numpy];
    env.NIX_CFLAGS_COMPILE = "-Wno-incompatible-pointer-types";
  };

  python = pkgs.python312;
  aubioSitePackages = "${aubio-python312}/${python.sitePackages}";
  numpySitePackages = "${pkgs.python312Packages.numpy}/${python.sitePackages}";

  picardWithAubio = pkgs.picard.overrideAttrs (old: {
    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [aubio-python312];
    qtWrapperArgs = (old.qtWrapperArgs or []) ++ [
      "--prefix PYTHONPATH : ${aubioSitePackages}:${numpySitePackages}"
    ];
  });

  picardPlugins = pkgs.fetchFromGitHub {
    owner = "metabrainz";
    repo = "picard-plugins";
    rev = "1ad24cca780406a980fda2940aba09e86a05fb47";
    hash = "sha256-T/G45uc+QMtkKVnGmYOxCkObfi4CztLwQRX8525/F+I=";
  };

  pluginDirs = ["lrclib_lyrics" "bpm" "replaygain2" "deezerart" "fanarttv" "lastfm"];
in {
  home.packages = [picardWithAubio pkgs.rsgain];

  xdg.configFile = lib.listToAttrs (map (name: {
    name = "MusicBrainz/Picard/plugins/${name}";
    value.source = "${picardPlugins}/plugins/${name}";
  }) pluginDirs);
}
