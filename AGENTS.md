# AGENTS.md - Repository Guide

This repository manages NixOS hosts and Home Manager profiles via a single flake.

## Scope

- **System configs:** `nixosConfigurations.sebastian-laptop-legion`
- **Home configs:** `homeConfigurations."sebastian@sebastian-laptop-legion"`
- **Platform:** `x86_64-linux` on NixOS unstable
- **Desktop:** selected in `shared/desktop.nix` (`"plasma"` or `"gnome"`); both module trees are kept in sync
- **Adding hosts:** register NixOS and Home Manager module paths in `hosts` in `flake.nix`; outputs and Home Manager checks are generated automatically

## Environment Details

- **Terminal:** Ghostty with Fish shell
- **Editor:** LazyVim (Neovim)
- **Theme:** Stylix (`purple-rain` base24)
- **Age key paths:** NixOS `/var/lib/sops-nix/key.txt`; Home Manager and `sops` CLI `~/.config/sops/age/keys.txt`

## Available Tools

- `comma` is installed system-wide for running packages from `nixpkgs` without adding them permanently. Use `, <command>`, for example `, cowsay neato`.

## Quick Commands

### Validate (safe, non-destructive)

```bash
# Show flake outputs (no lockfile writes)
nix flake show --no-write-lock-file

# Validate flake checks: alejandra formatting, actionlint, zizmor, Home Manager activation
# (CI in .github/workflows/check.yml also dry-runs the NixOS toplevel)
nix flake check . --quiet

# Dry-run Home Manager activation package build
nix build .#homeConfigurations.\"sebastian@sebastian-laptop-legion\".activationPackage --dry-run --quiet

# Dry-run NixOS system build (Legion)
nix build .#nixosConfigurations.sebastian-laptop-legion.config.system.build.toplevel --dry-run --quiet

# Full builds without creating a `./result` symlink
nix build .#homeConfigurations.\"sebastian@sebastian-laptop-legion\".activationPackage --no-link --print-out-paths --quiet
nix build .#nixosConfigurations.sebastian-laptop-legion.config.system.build.toplevel --no-link --print-out-paths --quiet

# Formatting check only
nix fmt . -- --check
```

### Apply configurations

```bash
# NixOS switch (Legion)
sudo nixos-rebuild switch --flake .#sebastian-laptop-legion --quiet

# NixOS test (temporary activation)
sudo nixos-rebuild test --flake .#sebastian-laptop-legion --quiet

# Home Manager switch
home-manager switch --flake .#sebastian@sebastian-laptop-legion

# nh equivalents (`build` builds without activating; result link goes to a temp dir, never pass `-o`/`--out-link`)
nh os build . -H sebastian-laptop-legion
nh os switch . -H sebastian-laptop-legion
nh home build . -c sebastian@sebastian-laptop-legion
nh home switch . -c sebastian@sebastian-laptop-legion
```

### Update inputs

```bash
# Update all inputs
nix flake update

# Update one input
nix flake update <input-name>

# Update one input and build in one step
nh os build . -H sebastian-laptop-legion -U <input-name>
```

### Secret management

```bash
# Run from home-manager/: .sops.yaml lives there and creation rules are only found from cwd upward
cd home-manager && sops secrets/<file>.yaml
```

## Module Loading

- `modules/nixos.nix`, `modules/common.nix`, and `modules/home-standalone.nix` recursively auto-import every file under `modules/` ending in `nixos.nix`, `common.nix`, or `home.nix`. No manual registration needed.
- Other files (e.g. `default.nix`, helpers) load only when imported from one of those; keep helpers off these suffixes to avoid accidental auto-import.
- Host-specific config: `nixos/hosts/<host>/` and `home-manager/hosts/<host>.nix`, registered in `hosts` in `flake.nix`.

## Code Conventions

- Use 2-space indentation.
- Use double quotes for strings.
- Use kebab-case filenames (example: `laptop-power.nix`).
- Split a module into `nixos.nix` / `home.nix` / `common.nix` by target; use `default.nix` only for subtrees imported explicitly.
- Format with `alejandra` via `nix fmt`.

## External Package Sources

- Prefer pinned `flake.nix` inputs (`flake = false` for non-flake sources, including binary release assets) over `fetchurl` in modules. Pass inputs through `extraSpecialArgs` and commit the resulting `flake.lock` update.
- Before packaging an upstream application from source, check for an existing Nix package and a usable binary release; on NixOS, patch or wrap prebuilt binaries to resolve their runtime dependencies.

## Commit Message Conventions

- Write commit subjects in English.
- Keep the subject concise, single-line, and focused on the change.
- Plain subjects start with a capitalized change verb, such as `Add`, `Enable`, `Fix`, `Update`, `Remove`, `Use`, or `Move`.
- Do not add a trailing period.
- History mixes plain subjects and `type(scope): summary` from `omp commit`; both are accepted.
- With a type prefix, use an area scope matching history (e.g. `ai`, `flake`, `plasma`, `nixos/legion`) and a past-tense lowercase summary.
- Use `fixup!` only for intentional autosquash commits.

## Common Patterns

### Module signature

```nix
{
  pkgs,
  config,
  lib,
  ...
}: {
  # Configuration here
}
```

### Shared environment values

```nix
let
  env = import ../../../../shared/env.nix;
in {
  # Use env.editor, env.terminal, env.browser, etc.
}
```

### SOPS secret declaration

```nix
sops.secrets.secret-name = {
  sopsFile = ../secrets/secret-name.yaml;
  path = "${config.home.homeDirectory}/.config/app/config";
};
```

### Securely passing secrets as env vars

Use secret file paths (`config.sops.secrets.<name>.path`) and load values at runtime.

```nix
# 1) Define secret (Home Manager or NixOS module)
sops.secrets."API_KEY" = {
  sopsFile = ../secrets/env-secrets.yaml;
  key = "API_KEY";
  format = "yaml";
};

# 2) Wrap binaries and export at runtime (preferred for CLI tools)
#    wrapWithSecrets = import ./wrap-with-secrets.nix {inherit pkgs lib;};  # modules/ai/
toolWrapped = wrapWithSecrets {
  pkg = pkgs.some-cli;
  binary = "some-cli";
  vars = {
    API_KEY = config.sops.secrets."API_KEY".path;
  };
};

# 3) For services, use environment files from sops paths
systemd.services.some-service.serviceConfig.EnvironmentFile =
  config.sops.secrets.some-service-env.path;
```

Do not put secret values in `home.sessionVariables`/`environment.variables`.
Do not inline secret values in Nix code or use `builtins.readFile` for secret content.

## Guardrails

1. Never edit `nixos/hosts/*/hardware-configuration.nix` manually.
2. Commit `flake.lock` after input updates.
3. Keep secrets encrypted at rest under `home-manager/secrets/`.
4. Do not make NixOS modules import Home Manager modules directly.
5. For Home Manager, do not use backup flags; allow activation conflicts to fail loudly.
6. Pass secrets to programs via SOPS-managed files and runtime loading, not plaintext Nix variables.

## Agent Notes

- Prefer quiet, non-interactive invocations for automation (`--quiet`, `--dry-run` where appropriate).
- `NH_FLAKE` is typically set in shell env vars, but repo-local `.` flake references are preferred in this file.
- Never leave a `result` symlink in the repo: use `nix build --no-link` (add `--print-out-paths` to inspect the output) or `nh ... build`, which links into a temp dir.
- Use `jq` for JSON parsing, not `python3 -m json.tool` or inline Python.
