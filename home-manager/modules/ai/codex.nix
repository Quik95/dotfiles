{
  pkgs,
  lib,
  config,
  ...
}: let
  wrapWithSecrets = import ./wrap-with-secrets.nix {
    inherit pkgs lib;
  };

  codexWrapped = wrapWithSecrets {
    pkg = pkgs.codex;
    binary = "codex";
    vars = {
      CODEX_ZAI_API_KEY = config.sops.secrets."CODEX_ZAI_API_KEY".path;
      CONTEXT7_API_KEY = config.sops.secrets."CONTEXT7_API_KEY".path;
    };
  };
in {
  home.sessionVariables = {
    CODEX_HOME = "${config.xdg.configHome}/codex";
  };

  programs.codex = {
    enable = true;
    package = codexWrapped;
    settings = {
      model = "gpt-5.3-codex";
    };
  };
}
