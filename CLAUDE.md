# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a chezmoi-based dotfiles repository for managing personal development environment configuration across Linux systems. The source directory is `home/` (set via `.chezmoiroot`).

Bootstrap on a new machine with `./install.sh`. Everything else is stock chezmoi (`apply`, `status`, `diff`, `edit`, `add`, `update`) — run `chezmoi --help` for those.

## Architecture

### Machine Detection System

The configuration uses template variables to adapt to different environments:

- **`personal`**: Set to `true` when hostname contains "noodle"
- **`ephemeral`**: Set to `true` for GitHub Codespaces, Docker, Vagrant, VSCode remote containers
- **`headless`**: Set to `true` when no display is available or connected via SSH

These variables are defined in `home/.chezmoi.toml.tmpl` and control which configurations and scripts are applied.

### Naming Conventions

- `dot_` prefix → `.` in target (e.g., `dot_zshrc` → `.zshrc`)
- `private_` prefix → mode 0600
- `exact_` prefix → remove files not managed by chezmoi
- `.tmpl` suffix → processed as Go template
- `run_onchange_before_*` → scripts that run before apply when content changes
- `run_onchange_after_*` → scripts that run after apply when content changes

### Version Configuration

Language/tool versions are centralized in `home/.chezmoidata.yaml`.

### External Dependencies

External archives and tools are managed via `home/.chezmoiexternal.toml.tmpl`:

- Oh-My-Zsh framework
- Fonts (Monaspace)
- CLI tools (glow)
