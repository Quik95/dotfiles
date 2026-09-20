{
  config,
  inputs,
  pkgs,
  ...
}: let
  ompPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.omp;
  ompWrapped = pkgs.symlinkJoin {
    name = "${ompPackage.pname}-with-home-manager-config";
    paths = [ompPackage];
    nativeBuildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram "$out/bin/omp" \
        --set PI_CONFIG_FILES "${config.xdg.configHome}/omp/home-manager.yml"
    '';
  };
  ompSettingsOverlay = (pkgs.formats.yaml {}).generate "omp-home-manager.yml" {
    astGrep.enabled = true;
    composer.tokenRate = true;
    defaultThinkingLevel = "low";
    advisor.enabled = true;
    modelRoles.advisor = "google-antigravity/gemini-3.8-flash";
    modelRoles.default = "openai-codex/gpt-5.6-luna:xhigh";
    providers.openai-codex.codeMode = "auto";
    setupVersion = 2;
    startup.quiet = true;
    statusLine = {
      compactThinkingLevel = false;
      transparent = true;
      preset = "custom";
      leftSegments = ["vim" "model" "mode" "path" "git" "pr"];
      rightSegments = ["session_name" "token_total" "context_pct"];
    };
    theme.dark = "titanium";
    terminal.showProgress = true;
    tui = {
      mouse = false;
      vimMode = true;
    };
  };
in {
  imports = [inputs.omp.homeManagerModules.default];

  programs.omp = {
    enable = true;
    package = ompWrapped;
    # OMP owns its mutable global config; Home Manager settings are a
    # read-only overlay, so onboarding and /settings can persist their state.
    settings = null;
  };

  xdg.configFile."omp/home-manager.yml".source = ompSettingsOverlay;
}
