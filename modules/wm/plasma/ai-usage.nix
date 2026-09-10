{
  lib,
  pkgs,
  hostname,
  inputs,
  ...
}: let
  aiUsage = inputs.kde-ai-usage.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        # Respect the same config directories as the installed coding agents.
        substituteInPlace contents/tools/aiusage/providers/claude_credentials.py \
          contents/tools/aiusage/collect.py \
          --replace-fail 'os.path.expanduser("~/.claude/' \
            'os.path.join(os.environ.get("CLAUDE_CONFIG_DIR", os.path.expanduser("~/.claude")), "'
        substituteInPlace contents/tools/aiusage/providers/openai_credentials.py \
          contents/tools/aiusage/providers/codex_stats.py \
          --replace-fail 'os.path.expanduser("~/.codex/' \
            'os.path.join(os.environ.get("CODEX_HOME", os.path.expanduser("~/.codex")), "'
      '';

    postInstall =
      (old.postInstall or "")
      + ''
        patchShebangs "$out/share/plasma/plasmoids/org.muddyblack.aiUsageWidget/contents/tools/sh"
      '';
  });
in {
  config = lib.mkIf (hostname == "sebastian-laptop-legion") {
    home.packages = [aiUsage];
  };
}
