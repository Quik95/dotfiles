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
- **Age key path:** `/var/lib/sops-nix/key.txt`

## Available Tools

- `comma` is installed system-wide for running packages from `nixpkgs` without adding them permanently. Use `, <command>`, for example `, cowsay neato`.

## Quick Commands

### Validate (safe, non-destructive)

```bash
# Show flake outputs (no lockfile writes)
nix flake show --no-write-lock-file

# Validate flake checks
nix flake check . --quiet

# Dry-run Home Manager activation package build
nix build .#homeConfigurations.\"sebastian@sebastian-laptop-legion\".activationPackage --dry-run --quiet

# Dry-run NixOS system build (Legion)
nix build .#nixosConfigurations.sebastian-laptop-legion.config.system.build.toplevel --dry-run --quiet

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

# nh equivalents (`build` builds without activating)
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
sops home-manager/secrets/<file>.yaml
```

## Directory Structure

```text
.
├── flake.nix
├── flake.lock
├── modules/
│   ├── common.nix
│   ├── nixos.nix
│   ├── home-standalone.nix
│   ├── core/
│   │   └── nixos.nix
│   └── ...
├── nixos/
│   ├── common.nix
│   ├── hosts/
│   │   └── sebastian-laptop-legion/
│   │       └── configuration.nix
├── home-manager/
│   ├── home.nix
│   ├── hosts/
│   └── secrets/
└── shared/
    └── env.nix
```

## Code Conventions

- Use 2-space indentation.
- Use double quotes for strings.
- Use kebab-case filenames (example: `laptop-power.nix`).
- Aggregate module imports in `default.nix` files.
- Format with `alejandra` via `nix fmt`.

## External Package Sources

- Prefer pinned `flake.nix` inputs (`flake = false` for non-flake sources, including binary release assets) over `fetchurl` in modules. Pass inputs through `extraSpecialArgs` and commit the resulting `flake.lock` update.
- Before packaging an upstream application from source, check for an existing Nix package and a usable binary release; on NixOS, patch or wrap prebuilt binaries to resolve their runtime dependencies.

## Commit Message Conventions

- Write commit subjects in English.
- Keep the subject concise, single-line, and focused on the change.
- Start with a capitalized change verb, such as `Add`, `Enable`, `Fix`, `Update`, `Remove`, `Use`, or `Move`.
- Do not add a trailing period.
- This repository's history does not use Conventional Commit prefixes or scopes.
- If `omp commit` adds its required type prefix, keep the summary in this style and leave the scope empty unless clearly useful.
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
- Use `jq` for JSON parsing, not `python3 -m json.tool` or inline Python.
