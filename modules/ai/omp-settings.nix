{
  config,
  inputs,
  lib,
  pkgs,
  sources,
  aiAgentsLspServers,
  aiAgentsBaseInstruction,
  ...
}: let
  ompPackage = pkgs.omp;
  # Puppeteer's downloaded Chromium is not patched for NixOS; reuse CloakBrowser.
  ompBrowserPackage = inputs.cloakbrowser.packages.${pkgs.stdenv.hostPlatform.system}.cloakbrowserChromium;
  ompBrowserProfile = "${config.xdg.stateHome}/omp-browser/profile";
  # omp exposes no profile setting; the trailing switch wins over omp's own
  # --user-data-dir, so every launch reuses one persistent profile.
  ompBrowser = pkgs.writeShellScript "omp-browser" ''
    ${pkgs.coreutils}/bin/mkdir -p -- ${lib.escapeShellArg ompBrowserProfile}
    exec ${lib.getExe ompBrowserPackage} "$@" --user-data-dir=${lib.escapeShellArg ompBrowserProfile}
  '';
  # Install at launch rather than activation: PI_CODING_AGENT_DIR is a runtime choice.
  ompInstallRules = pkgs.writeShellScript "omp-install-rules" ''
    set -euo pipefail
    rules_dir="''${PI_CODING_AGENT_DIR:-$HOME/.omp/agent}/rules"
    ${pkgs.coreutils}/bin/mkdir -p -- "$rules_dir"
    ${pkgs.coreutils}/bin/install -m 0644 -- ${./omp-rules}/*.md "$rules_dir/"
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
        --set PI_CONFIG_FILES "${config.xdg.configHome}/omp/home-manager.yml" \
        --set-default PUPPETEER_EXECUTABLE_PATH "${ompBrowser}" \
        --run '${ompInstallRules} || exit $?'

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
      default = "openai-codex/gpt-6.1-sol:low";
      task = "openai-codex/gpt-6.1-sol:low";
      smol = "openai-codex/gpt-6-luna:medium";
      tiny = "openai-codex/gpt-6-luna:low";
      slow = "openai-codex/gpt-6.1-sol:high";
      plan = "openai-codex/gpt-6.1-sol:xhigh";
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
  ompMcpServers =
    lib.mapAttrs (
      _: server:
        if server.url != null
        then {
          type = "http";
          inherit (server) url headers;
        }
        else {
          inherit (server) command args env;
        }
    )
    (removeAttrs config.programs.mcp.servers ["agent-browser"]);
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
      freezeOnTurnEnd = false;
      idleCloseSec = 0;
    };
    python.interpreter = lib.getExe pkgs.python3;
    composer.tokenRate = true;
    display.cacheMissMarker = true;
    defaultThinkingLevel = "low";
    advisor.enabled = false;
    enabledModels = [
      "openai-codex/gpt-6-astra"
      "openai-codex/gpt-6.1-sol"
      "openai-codex/gpt-6-luna"
      "anthropic/claude-opus-5-5"
      "google-antigravity/gemini-3.8-flash"
    ];
    hideThinkingBlock = false;
    modelRoles = {
      advisor = "openai-codex/gpt-6-luna:medium";
      commit = "google-antigravity/gemini-3.8-flash:low";
      default = "openai-codex/gpt-6.1-sol:low";
      slow = "openai-codex/gpt-6.1-sol:high";
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
  home.file.".omp/agent/AGENTS.md".text = aiAgentsBaseInstruction;
  home.file.".omp/agent/lsp.json".source = (pkgs.formats.json {}).generate "omp-lsp.json" {
    servers =
      lib.mapAttrs (_: server:
        {
          command = builtins.head server.command;
          args = builtins.tail server.command;
          fileTypes = builtins.attrNames server.extensionToLanguage;
          rootMarkers = ["."];
        }
        // lib.optionalAttrs (server ? settings) {
          inherit (server) settings;
        }
        // lib.optionalAttrs (server ? isLinter) {
          inherit (server) isLinter;
        })
      (lib.filterAttrs (_: server: server.extensionToLanguage != {}) aiAgentsLspServers)
      // {
        typescript-language-server.disabled = true;
        typescript-native.disabled = true;
        vscode-html-language-server.disabled = true;
        omnisharp.disabled = true;
      };
  };

  home.file.".omp/plugins/node_modules/@ahrzb/omp-model-presets".source = sources.omp-model-presets.src;
  home.file.".omp/plugins/package.json".text = builtins.toJSON {
    name = "omp-plugins";
    private = true;
    dependencies = {
      "@ahrzb/omp-model-presets" = "^${sources.omp-model-presets.version}";
    };
  };
  home.file.".omp/plugins/omp-plugins.lock.json".text = builtins.toJSON {
    plugins = {
      "@ahrzb/omp-model-presets" = {
        version = sources.omp-model-presets.version;
        enabledFeatures = null;
        enabled = true;
      };
    };
    settings = {};
  };

  home.file.".omp/agent/models.yml".source = (pkgs.formats.yaml {}).generate "omp-models.yml" {
    providers.anthropic.modelOverrides.claude-opus-5-5 = {
      contextWindow = 350000;
      maxContextWindow = 1000000;
    };
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
