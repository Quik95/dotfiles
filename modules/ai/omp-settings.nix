{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: let
  ompPackage = pkgs.omp;
  ompRelayExtension = pkgs.runCommand "omp-browser-relay-extension" {} ''
    ${ompPackage}/bin/omp browser-relay install --dir "$out"
  '';
  ompWrapped = pkgs.symlinkJoin {
    name = "${ompPackage.pname}-with-home-manager-config";
    paths = [ompPackage];
    nativeBuildInputs = [
      pkgs.makeWrapper
      pkgs.installShellFiles
    ];
    postBuild = ''
      wrapProgram "$out/bin/omp" \
        --set PI_CONFIG_FILES "${config.xdg.configHome}/omp/home-manager.yml"

      ${lib.optionalString (pkgs.stdenv.buildPlatform.canExecute pkgs.stdenv.hostPlatform) ''
        HOME=$TMPDIR $out/bin/omp completions fish > omp.fish
        HOME=$TMPDIR $out/bin/omp completions bash > omp.bash
        HOME=$TMPDIR $out/bin/omp completions zsh > _omp
        installShellCompletion --cmd omp \
          --bash --name omp omp.bash \
          --fish --name omp.fish omp.fish \
          --zsh --name _omp _omp
      ''}
    '';
  };
  ompModelPresetsData = {
    gpt = {
      default = "openai-codex/gpt-6-sol:low";
      task = "openai-codex/gpt-6-sol:low";
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
  ompMcpServers = lib.mapAttrs (
    _: server:
      if server.url != null
      then {
        type = "http";
        inherit (server) url headers;
      }
      else {
        inherit (server) command args env;
      }
  ) (builtins.removeAttrs config.programs.mcp.servers ["agent-browser"]);
  ompMcpConfig = (pkgs.formats.json {}).generate "omp-mcp.json" {
    mcpServers =
      ompMcpServers
      // {
        context7 =
          ompMcpServers.context7
          // {
            headers.Authorization = "!printf 'Bearer %s' \"$(cat ${lib.escapeShellArg config.sops.secrets."CONTEXT7_API_KEY".path})\"";
          };
      };
  };
  ompSettingsOverlay = (pkgs.formats.yaml {}).generate "omp-home-manager.yml" {
    memory.backend = "mnemopi";
    astGrep.enabled = true;
    browser = {
      headless = false;
      relay = true;
    };
    composer.tokenRate = true;
    display.cacheMissMarker = true;
    defaultThinkingLevel = "low";
    advisor.enabled = false;
    enabledModels = [
      "openai-codex/gpt-6-sol"
      "openai-codex/gpt-6-luna"
      "anthropic/claude-opus-5-5"
      "google-antigravity/gemini-3.8-flash"
    ];
    hideThinkingBlock = false;
    modelRoles = {
      advisor = "openai-codex/gpt-6-luna:medium";
      commit = "google-antigravity/gemini-3.8-flash:low";
      default = "openai-codex/gpt-6-sol:low";
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
  home.file.".omp/agent/mcp.json".source = ompMcpConfig;
  home.file.".omp/browser-relay/extension".source = ompRelayExtension;

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
