{
  pkgs,
  lib,
  inputs,
  ...
}: let
  agentLib = import "${inputs.agent-skills}/lib" {inherit lib inputs;};

  # Vendored here only when no maintained upstream skill exists.
  sources = {
    local = {
      path = ./.;
      filter.maxDepth = 1;
    };
    typst = {
      input = "typst-skills";
      filter.maxDepth = 1;
    };
    opencode-power-pack = {
      input = "opencode-power-pack";
      subdir = "skills";
      filter.maxDepth = 1;
    };
    ast-grep = {
      input = "ast-grep-skill";
      subdir = "ast-grep/skills";
      filter.maxDepth = 1;
    };
    bigboss = {
      input = "bigboss-skills";
      subdir = ".claude/skills";
      filter.maxDepth = 1;
    };
    shell-scripting = {
      input = "wshobson-agents";
      subdir = "plugins/shell-scripting/skills";
      filter.maxDepth = 1;
    };
  };

  catalog = agentLib.discoverCatalog sources;
  bundle = agentLib.mkBundle {
    inherit pkgs;
    selection = agentLib.selectSkills {
      inherit catalog sources;
      allowlist = [
        "powershell-expert"
        "semble"
        "typst-author"
        "agents-md-improver"
        "ast-grep"
        "nix-best-practices"
        "bash-defensive-patterns"
        "shellcheck-configuration"
      ];
      skills = {};
    };
  };
in {
  # Both modules link a skills directory recursively, so unmanaged entries
  # (Codex `.system`, Claude `synced`) stay untouched.
  programs.claude-code.skills = bundle;
  programs.codex.skills = bundle;
}
