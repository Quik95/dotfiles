{
  lib,
  pkgs,
  inputs,
  ...
}: let
  isPlasma = (import ../../../shared/desktop.nix).desktop == "plasma";
  aiUsage = inputs.tidesi.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    postPatch =
      (old.postPatch or "")
      + ''
        # Upstream honors CLAUDE_CONFIG_DIR everywhere except the stats/settings reads.
        substituteInPlace backend/tidesi/collect.py \
          --replace-fail 'os.path.expanduser("~/.claude/' \
            'os.path.join(os.environ.get("CLAUDE_CONFIG_DIR") or os.path.expanduser("~/.claude"), "'
      '';

    postInstall =
      (old.postInstall or "")
      + ''
        patchShebangs "$out/share/plasma/plasmoids/org.muddyblack.tidesi/contents/backend/sh"
      '';
  });
in {
  config = lib.mkIf isPlasma {
    home.packages = [aiUsage];
  };
}
