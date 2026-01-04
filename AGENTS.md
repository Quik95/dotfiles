# AGENTS.md - Repository Guide

This is a NixOS + Home Manager flake-based dotfiles repository. Use this guide to understand the codebase structure, conventions, and essential commands.

## Project Overview

This repository contains:
- **NixOS system configuration** (`nixos/`) - System-level settings, services, and packages
- **Home Manager configuration** (`home-manager/`) - User-level dotfiles, applications, and shell configuration
- **Shared configuration** (`shared/`) - Environment variables shared between system and user configs

The configuration is managed using Nix flakes and deployed with `nh` (Nix Helper).

## Essential Commands

### Applying Configuration Changes

**System-level (NixOS):**
```bash
# Apply NixOS configuration
sudo nh os switch /home/sebastian/Documents/dotfiles

# Test configuration without persisting
sudo nh os test /home/sebastian/Documents/dotfiles

# Build without switching
sudo nh os build /home/sebastian/Documents/dotfiles
```

**User-level (Home Manager):**
```bash
# Apply Home Manager configuration
nh home switch /home/sebastian/Documents/dotfiles

# Test without persisting
nh home test /home/sebastian/Documents/dotfiles

# Build without switching
nh home build /home/sebastian/Documents/dotfiles
```

### Updating and Maintenance

```bash
# Update flake inputs
nix flake update

# Clean old generations (keeps last 3 and those from last 5 days)
sudo nh clean all

# Check flake for errors
nix flake check

# Show configuration diff before applying
sudo nh os switch /home/sebastian/Documents/dotfiles --dry-activate
```

### Secret Management (sops-nix)

```bash
# Edit secrets (encrypted)
sops home-manager/secrets/secret-name.yaml

# View secrets
sops decrypt home-manager/secrets/secret-name.yaml

# Re-key secrets (if age key changes)
sops updatekeys --yes home-manager/secrets/*.yaml
```

### Nix Helper (nh) Configuration

The `nh` tool is configured in `nixos/modules/nh.nix` with:
- Flake path: `/home/sebastian/Documents/dotfiles`
- Automatic cleanup: Keeps last 3 generations and those from 5 days

## Code Organization

### Directory Structure

```
.
├── flake.nix              # Top-level flake definition and outputs
├── flake.lock             # Pinned dependency versions
├── shared/
│   └── env.nix            # Shared environment variables (editor, terminal, etc.)
├── nixos/
│   ├── configuration.nix  # Main NixOS configuration
│   ├── hardware-configuration.nix  # Auto-generated hardware config (DO NOT EDIT)
│   └── modules/
│       ├── default.nix    # Module imports
│       └── *.nix          # System-level modules
└── home-manager/
    ├── home.nix           # Main Home Manager configuration
    ├── modules/           # User-level modules
    ├── hosts/             # Host-specific configurations (if needed)
    └── secrets/           # Encrypted secrets managed by sops-nix
```

### Module Organization

**NixOS modules** (`nixos/modules/`):
- `wm/` - Window manager configuration (GNOME)
- `ananicy.nix` - Community rules for ananicy-cpp
- `btrfs.nix` - BTRFS filesystem settings
- `laptop-power.nix` - Power management optimizations
- `nh.nix` - Nix Helper configuration
- `packages.nix` - System-wide packages and shells
- `pam.nix` - PAM configuration
- `virtualization.nix` - Virtualization settings
- `wifi-manager.nix` - WiFi/ethernet auto-switching

**Home Manager modules** (`home-manager/modules/`):
- `browsers/` - Browser configurations (Firefox, Chrome)
- `ide/` - IDE configurations (Neovim, Helix, JetBrains, VSCode, Zed)
- `multimedia/` - Multimedia tools (Foliate, MPV, yt-dlp)
- `sdk/` - Development SDKs (C, Rust)
- `terminal/` - Terminal tools and shells
  - `terminal-emulators/` - Ghostty, Kitty
  - `shells/` - Fish shell configuration
- `wm/` - Window manager configs (GNOME settings, extensions, dconf)
- `default-apps.nix` - Default application associations
- `dropbox.nix` - Dropbox setup
- `env-vars.nix` - Environment variables
- `flatpak.nix` - Flatpak integration
- `misc.nix` - Miscellaneous settings
- `sops.nix` - Secret management setup
- `ssh.nix` - SSH and GPG configuration
- `stylix.nix` - Theme system (base16 colorschemes)

## Code Conventions and Patterns

### Module Structure

**Standard module pattern:**
```nix
{
  pkgs,
  config,
  ...
}: {
  # Configuration here
}
```

**Module with custom options:**
```nix
{
  pkgs,
  config,
  options,
  lib,
  ...
}: {
  options = {
    custom.option-name = lib.mkOption {
      type = lib.types.path;
      default = "default-value";
      description = "Description";
    };
  };

  config = {
    # Configuration that uses the options
  };
}
```

**Module with imports:**
```nix
{
  imports = [
    ./submodule1.nix
    ./submodule2.nix
  ];
}
```

### Imports and Shared Values

**Import shared environment variables:**
```nix
let
  env = import ../../../../shared/env.nix;
in {
  # Use env.editor, env.terminal, etc.
}
```

**Module aggregation pattern:**
- `default.nix` files aggregate related modules
- Each module directory has a `default.nix` that imports submodules
- This keeps imports organized and hierarchical

### Package Management

**Adding system packages:**
```nix
environment.systemPackages = with pkgs; [
  package1
  package2
];
```

**Adding home packages:**
```nix
home.packages = with pkgs; [
  package1
  package2
];
```

### Program Configuration

**Standard program module:**
```nix
programs.program-name = {
  enable = true;
  settings = {
    # Configuration values
  };
};
```

### Shell Script Embedding

For systemd services or complex logic, use `writeShellScript`:
```nix
let
  script = pkgs.writeShellScript "script-name.sh" ''
    #!/usr/bin/env bash
    set -euo pipefail
    # script content here
  '';
in {
  systemd.services.service-name = {
    serviceConfig.ExecStart = "${script}";
  };
}
```

## Important Patterns

### Secret Management with sops-nix

Secrets are encrypted with age keys defined in `home-manager/.sops.yaml`:
- All secrets in `home-manager/secrets/` are encrypted
- Decryption keys stored in `${config.xdg.configHome}/sops/age/keys.txt`
- Secrets are decrypted at activation time and placed at specified paths

**Secret definition pattern:**
```nix
sops.secrets.secret-name = {
  sopsFile = ../secrets/secret-name.yaml;
  path = "${config.home.homeDirectory}/.config/app/config";
};
```

Binary secrets use `format = "binary"`.

### Theming with Stylix

Stylix provides unified theming across applications:
- Base16 color scheme from `tinted-theming/schemes`
- Applied to: bat, btop, fish, firefox, ghostty, helix, kde, kitty, lazygit, mpv, neovim
- Theme configuration in `home-manager/modules/stylix.nix`

### Custom Options Pattern

The repository defines custom options in modules (e.g., SSH module defines `custom.gpg.homedirLocation`):
- Use `lib.mkOption` to define options
- Import and use in other modules via `config.custom.option-name`

### Git Configuration

- Git is configured with aliases for common operations
- Git signing is enabled by default with openpgp format
- Conditional git config for different project directories (e.g., university projects)

### Editor Configuration

Multiple editors are configured:
- **Neovim (nixvim)**: Primary editor, configured with Lua plugins
- **Helix**: Available but disabled by default
- **JetBrains IDEs**: Available via home manager
- **VSCode**: Available via home manager
- **Zed**: Available via home manager

The default editor is determined by `env.editor` from `shared/env.nix`.

### Terminal Setup

- **Shell**: Fish with vi-mode bindings
- **Terminal emulator**: Ghostty (from `env.terminal`)
- **Prompt**: Starship
- **Aliases**: Defined in `home-manager/modules/terminal/shells/fish/default.nix`
- **History**: Managed by atuin

### Window Manager

- **GNOME**: Primary window manager
- Configuration split across multiple files: dconf, extensions, monitors, nautilus
- Extensions managed declaratively
- Theme applied via Stylix

## Gotchas and Important Notes

### Hardware Configuration

- **DO NOT EDIT** `nixos/hardware-configuration.nix`
- This file is auto-generated by `nixos-generate-config`
- Changes may be overwritten by system updates
- Hardware-specific changes should go in other modules

### Build System

- No traditional test suite (this is a configuration repo, not software)
- Validation is done by applying the configuration
- Use `--dry-activate` to preview changes
- `nix flake check` can validate flake structure

### NixOS vs Home Manager

- **NixOS modules**: System-wide settings, services, kernels, hardware
- **Home Manager modules**: User-specific applications, dotfiles, shell config
- Home Manager can import from NixOS but not vice versa
- Some settings require both (e.g., if a system service depends on user config)

### Dependency Management

- All external dependencies are declared in `flake.nix` inputs
- Pinned versions in `flake.lock` - commit this file for reproducibility
- Use `nix flake update` to update all inputs
- Target specific inputs: `nix flake lock --update-input input-name`

### Experimental Features

- Nix is configured with experimental features: `nix-command` and `flakes`
- This is required for flake-based workflows
- Trusted users: root and sebastian (from NixOS config)

### Cache

- Using `devenv.cachix.org` as additional binary cache
- Cache URL and public key in `nixos/configuration.nix`
- Speeds up builds by reusing cached packages

### Localization

- Timezone: Europe/Warsaw
- Default locale: en_US.UTF-8
- Regional locales set to pl_PL.UTF-8
- Keyboard layout: Polish (pl2)

## Style Guidelines

### Code Style

- Use 2-space indentation
- Use double quotes for strings
- Use `{` on same line as function name
- Use trailing commas for lists (Nix syntax requirement)
- Comment with `#` at line start
- Keep lines under 80-100 characters when practical

### File Naming

- Module files: kebab-case (e.g., `laptop-power.nix`)
- Default module index: `default.nix`
- Secret files: descriptive names (e.g., `github-ssh-key.yaml`)

### Module Placement

- System-level settings → `nixos/modules/`
- User-level settings → `home-manager/modules/`
- Shared values → `shared/env.nix`
- Create subdirectories for related modules (e.g., `browsers/`, `terminal/`)

### Import Ordering

1. External flake imports (first in file)
2. Relative imports (after external)
3. Group related imports together
4. Keep imports in alphabetical order when no logical grouping exists

## Testing Changes

Before committing configuration changes:

1. **Check syntax:**
   ```bash
   nix flake check
   ```

2. **Preview changes:**
   ```bash
   sudo nh os switch /home/sebastian/Documents/dotfiles --dry-activate
   ```

3. **Apply and test:**
   ```bash
   sudo nh os test /home/sebastian/Documents/dotfiles
   nh home test /home/sebastian/Documents/dotfiles
   ```

4. **Verify services:**
   ```bash
   systemctl status <service-name>
   ```

5. **Check logs if something fails:**
   ```bash
   journalctl -xe
   ```

## Common Tasks

### Adding a new package

1. Find package: `nix search nixpkgs package-name`
2. Add to appropriate list:
   - System package → `nixos/modules/packages.nix`
   - Home package → `home-manager/home.nix` or relevant module
3. Rebuild: `sudo nh os switch /home/sebastian/Documents/dotfiles` or `nh home switch /home/sebastian/Documents/dotfiles`

### Adding a new module

1. Create `.nix` file in appropriate directory
2. Add import to parent module's `default.nix`
3. Follow module structure patterns
4. Test with `nix flake check` and rebuild

### Managing secrets

1. Create secret: `sops home-manager/secrets/secret-name.yaml`
2. Add secret definition in `home-manager/modules/sops.nix`
3. Use decrypted path in configuration
4. Test: `nh home switch /home/sebastian/Documents/dotfiles`

### Changing theme

1. Update base16 scheme URL in `home-manager/modules/stylix.nix`
2. Apply: `nh home switch /home/sebastian/Documents/dotfiles`
3. Stylix will automatically theme all enabled targets
