# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Apply configuration to current host
nh os switch .

# Format all Nix files
alejandra .

# Lint
statix check .

# Build a specific package
nix build .#<package>

# Run all checks (including inline module tests)
nix flake check

# Run a specific NixOS integration test
nix build .#checks.x86_64-linux.desktop

# Interactive test VM (for debugging tests)
nix run .#checks.x86_64-linux.desktop.driverInteractive
```

## Architecture

### Auto-import system

`flake.nix` recursively collects every `.nix` file except `flake.nix` itself and files whose names start with `_`. Each file is loaded as a `flake-parts` module. There is no central module list to maintain — adding a `.nix` file is sufficient.

Files prefixed with `_` are intentionally excluded (used for data/helpers that should not be treated as modules).

### Module naming convention

Each file declares its output under a key like `flake.nixosModules.<name>` (e.g. `flake.nixosModules.desktop`). Hosts then compose these by importing `self.nixosModules.<name>`.

### Host structure

Three hosts under `nixos/hosts/`:
- **main** — AMD desktop with impermanence (btrfs), disko, ALVR, OBS
- **mini** — lightweight laptop
- **herman** — Microsoft Surface Pro 4 (uses `nixos-hardware`)

### Custom options

**`preferences.user.*`** (defined in `nixos/base/user.nix`): `name`, `timezone`, `authorizedKeys` — used throughout modules instead of hardcoding the username.

**`persistance.*`** (defined in `nixos/base/persistance.nix`, note the intentional spelling): wraps the `impermanence` module with three buckets:
- `persistance.data.{directories,files}` → `/persist/userdata`
- `persistance.cache.{directories,files}` → `/persist/usercache`
- `persistance.{directories,files}` → `/persist/system`

Enable impermanence on a host by importing `self.nixosModules.impermanence`, which sets `persistance.enable = true`.

### wrappedPrograms

`wrappedPrograms/` contains program configurations using `wrapper-modules` and `wrappers` flake inputs. They export `perSystem.packages.<name>` entries. Key packages:
- `environment` — fish shell wrapped with all CLI tools in PATH
- `terminal` — kitty using `environment` as its shell
- `desktop` — niri window manager (the full desktop)
- `neovim` / `neovimDynamic` — neovim with plugins; dynamic mode reads config live from `~/nixconf/wrappedPrograms/neovim/`

### Theme

`theme.nix` exports `self.theme` (base16 hex colors with `#`) and `self.themeNoHash` (without `#`). It's a gruvbox-dark palette. Reference colors as `self.theme.base0X` or `self.themeNoHash.base0X` in other modules.

### Testing

Tests are written inline within their feature module (e.g. the `desktop` check lives inside `nixos/features/desktop.nix`) under the `perSystem.checks.<name>` key. Run all checks with `nix flake check`. The `desktop` check boots a NixOS VM and verifies niri starts and renders a non-black screen.

### Dendritic Nix

This config uses [Dendritic Nix](https://dendrix.oeiuwq.com/Dendritic.html) — a structured approach to composing NixOS modules.
