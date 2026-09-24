{
  config,
  inputs,
  lib,
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
  ompModelPresetsData = {
    gpt = {
      default = "openai-codex/gpt-6-luna:xhigh";
      task = "openai-codex/gpt-6-luna:xhigh";
      smol = "openai-codex/gpt-6-luna:medium";
      tiny = "openai-codex/gpt-6-luna:low";
      slow = "openai-codex/gpt-6-sol:high";
      plan = "openai-codex/gpt-6-sol:xhigh";
      commit = "google-antigravity/gemini-3.8-flash:low";
      vision = "google-antigravity/gemini-3.8-flash:medium";
    };
    claude = {
      default = "anthropic/claude-opus-5-5:medium";
      task = "anthropic/claude-opus-5-5:medium";
      smol = "google-antigravity/gemini-3.8-flash:medium";
      tiny = "google-antigravity/gemini-3.8-flash:low";
      slow = "anthropic/claude-opus-5-5:high";
      plan = "anthropic/claude-opus-5-5:high";
      advisor = "openai-codex/gpt-6-luna:high";
      commit = "google-antigravity/gemini-3.8-flash:low";
      vision = "google-antigravity/gemini-3.8-flash:medium";
    };
  };
  ompModelPresetsFile = (pkgs.formats.json {}).generate "omp-model-presets.json" ompModelPresetsData;
  ompModelPresetsPath = "${config.home.homeDirectory}/.omp/agent/model-presets.json";
  ompModelPresetsActivePath = "${config.home.homeDirectory}/.omp/agent/model-presets.active";
  ompSettingsOverlay = (pkgs.formats.yaml {}).generate "omp-home-manager.yml" {
    memory.backend = "mnemopi";
    astGrep.enabled = true;
    composer.tokenRate = true;
    defaultThinkingLevel = "low";
    advisor.enabled = false;
    modelRoles = {
      advisor = "anthropic/claude-haiku-4-5:medium";
      commit = "google-antigravity/gemini-3.8-flash:low";
      default = "openai-codex/gpt-6-luna:xhigh";
      slow = "openai-codex/gpt-6-sol:high";
    };
    providers.openai-codex.codeMode = "off";
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

  home.file.".omp/plugins/node_modules/@ahrzb/omp-model-presets".source = inputs.omp-model-presets;
  home.file.".omp/plugins/package.json".text = builtins.toJSON {
    name = "omp-plugins";
    private = true;
    dependencies = {
      "@ahrzb/omp-model-presets" = "^0.10.0";
    };
  };
  home.file.".omp/plugins/omp-plugins.lock.json".text = builtins.toJSON {
    plugins = {
      "@ahrzb/omp-model-presets" = {
        version = "0.10.0";
        enabledFeatures = null;
        enabled = true;
      };
    };
    settings = {};
  };

  home.file.".omp/agent/models.yml".source = (pkgs.formats.yaml {}).generate "omp-models.yml" {
    providers.anthropic.modelOverrides.claude-opus-5-5.contextWindow = 350000;
  };

  home.activation.installOmpModelPresets = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ ! -v DRY_RUN ]]; then
      install -d -m 0755 "$(dirname "${ompModelPresetsPath}")"
      rm -f "${ompModelPresetsPath}"
      install -m 0644 "${ompModelPresetsFile}" "${ompModelPresetsPath}"
      if [[ ! -f "${ompModelPresetsActivePath}" ]]; then
        echo "gpt" > "${ompModelPresetsActivePath}"
      fi
    fi
  '';
}
