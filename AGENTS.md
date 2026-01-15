# AGENTS.md - Repository Guide

This is a declarative NixOS and Home Manager dotfiles repository using Nix flakes for reproducible system configuration.

## Quick Reference

### Apply Configurations

```bash
# System configuration (NixOS)
sudo nixos-rebuild switch --flake $NH_FLAKE --quiet

# User configuration (Home Manager)
home-manager switch --flake $NH_FLAKE

# Test without persisting (add --dry-run for no changes)
sudo nixos-rebuild test --flake $NH_FLAKE --quiet
home-manager build --flake $NH_FLAKE
```

### Validation

```bash
nix flake check $NH_FLAKE      # Validate flake structure and syntax
nix flake update               # Update all inputs
nix flake update <name>        # Update specific input
```

### Agent/CI Usage

Use these non-interactive flags with nix commands:
- `--quiet` or `-q` - Minimize output (show errors only)
- `--ask` - Request confirmation before switching (nh only)
- `--accept-flake-config` - Auto-accept flake config settings (nh only)

Do NOT use `-b backup` with home-manager. Let it fail on conflicts so issues are surfaced.

```bash
# Quiet build check (agents should use this)
nix build $NH_FLAKE#homeConfigurations.sebastian.activationPackage --dry-run --quiet

# Format check without modifying
nix fmt $NH_FLAKE -- --check
```

### Secret Management

```bash
sops home-manager/secrets/<file>.yaml  # Edit encrypted secret
```

## Directory Structure

```
├── flake.nix                 # Flake definition with inputs/outputs
├── flake.lock                # Pinned dependencies (commit this)
├── nixos/
│   ├── configuration.nix     # Main NixOS config
│   ├── hardware-configuration.nix  # DO NOT EDIT - auto-generated
│   └── modules/              # System-level modules
├── home-manager/
│   ├── home.nix              # Main Home Manager config
│   ├── modules/              # User-level modules
│   ├── secrets/              # sops-encrypted secrets
│   └── .sops.yaml            # sops configuration
└── shared/
    └── env.nix               # Shared environment variables
```

## Code Conventions

- **Indentation:** 2 spaces
- **Strings:** Double quotes
- **File naming:** kebab-case (e.g., `laptop-power.nix`)
- **Module aggregation:** Use `default.nix` to import submodules
- **Formatter:** alejandra (`nix fmt`)

## Common Patterns

### Module Structure

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

### Using Shared Environment

```nix
let
  env = import ../../../../shared/env.nix;
in {
  # Use env.editor, env.terminal, env.browser, etc.
}
```

### Defining Secrets

```nix
sops.secrets.secret-name = {
  sopsFile = ../secrets/secret-name.yaml;
  path = "${config.home.homeDirectory}/.config/app/config";
};
```

### Program Configuration

```nix
programs.program-name = {
  enable = true;
  settings = { /* config */ };
};
```

## Key Information

- **System:** NixOS unstable on x86_64-linux
- **Desktop:** GNOME
- **Terminal:** Ghostty with Fish shell
- **Editor:** Neovim (nixvim)
- **Theme:** Stylix with purple-rain base24

## Important Notes

1. **hardware-configuration.nix** is auto-generated - never edit manually
2. **flake.lock** must be committed for reproducibility
3. NixOS modules cannot import Home Manager modules directly
4. Secrets are encrypted at rest and decrypted at activation time
5. Age keys are stored at `~/.config/sops/age/keys.txt`
