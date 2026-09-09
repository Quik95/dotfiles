{
  lib,
  pkgs,
  hostname,
  ...
}: let
  aiUsage = pkgs.stdenvNoCC.mkDerivation {
    pname = "kde-ai-usage";
    version = "2.1.2";

    src = pkgs.fetchFromGitHub {
      owner = "Muddyblack";
      repo = "kde-ai-usage";
      rev = "5bc956931711708993c8b834a016bc6d2b43b7e9";
      hash = "sha256-+GW1SU9h0JrNZh2g8xWt9YBtoXfCZ38rLMy2TmTFJl8=";
    };

    dontBuild = true;
    postPatch = ''
      # Respect the same config directories as the installed coding agents.
      substituteInPlace package/contents/tools/aiusage/providers/claude_credentials.py \
        package/contents/tools/aiusage/collect.py \
        --replace-fail 'os.path.expanduser("~/.claude/' \
          'os.path.join(os.environ.get("CLAUDE_CONFIG_DIR", os.path.expanduser("~/.claude")), "'
      substituteInPlace package/contents/tools/aiusage/providers/openai_credentials.py \
        package/contents/tools/aiusage/providers/codex_stats.py \
        --replace-fail 'os.path.expanduser("~/.codex/' \
          'os.path.join(os.environ.get("CODEX_HOME", os.path.expanduser("~/.codex")), "'
    '';

    installPhase = ''
      runHook preInstall
      widgetDir="$out/share/plasma/plasmoids/org.muddyblack.aiUsageWidget"
      mkdir -p "$widgetDir"
      cp -r package/. "$widgetDir/"

      # Plasma's session PATH need not include Python.
      substituteInPlace "$widgetDir/contents/tools/sh/python-interp.sh" \
        --replace-fail 'PY_DEFAULT="python3"' 'PY_DEFAULT="${pkgs.python3}/bin/python3"'
      patchShebangs "$widgetDir/contents/tools/sh"

      install -Dm644 package/contents/icons/org.muddyblack.aiUsageWidget.svg \
        "$out/share/icons/hicolor/scalable/apps/org.muddyblack.aiUsageWidget.svg"
      runHook postInstall
    '';

    meta = {
      description = "Plasma widget for AI usage limits and history";
      homepage = "https://github.com/Muddyblack/kde-ai-usage";
      license = lib.licenses.mit;
      platforms = lib.platforms.linux;
    };
  };
in {
  config = lib.mkIf (hostname == "sebastian-laptop-legion") {
    home.packages = [aiUsage];
  };
}
