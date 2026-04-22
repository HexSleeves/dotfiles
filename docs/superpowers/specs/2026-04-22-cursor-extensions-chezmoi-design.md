# Cursor Extensions — chezmoi Integration

**Date:** 2026-04-22
**Status:** Approved

## Problem

Cursor extensions are not tracked in the chezmoi dotfiles repo. On a new machine, extensions must be reinstalled manually. `settings.json` and `keybindings.json` are already managed; extensions are the missing piece.

## Goals

- Track the installed Cursor extension list in git
- Auto-install missing extensions on `chezmoi apply` (additive only, no uninstall)
- Provide a manual export script to refresh the list after extension changes

## Out of Scope

- Bidirectional sync (uninstalling extensions removed from list)
- Automatic export on extension install/remove
- VSCode extension management (cursor only)

## File Layout

```
home/
├── dot_cursor/
│   └── extensions/
│       └── list.txt                                       # tracked list, one ID per line, sorted
├── dot_local/bin/
│   └── executable_save-cursor-extensions                  # export script (~/.local/bin/save-cursor-extensions)
└── run_onchange_after_install-cursor-extensions.sh.tmpl   # install script, runs when list.txt changes
```

## Components

### `dot_cursor/extensions/list.txt`

Plain text file, one Cursor extension ID per line, alphabetically sorted. Committed to git. Deployed to `~/.cursor/extensions/list.txt`.

Example:
```
biomejs.biome
bradlc.vscode-tailwindcss
dbaeumer.vscode-eslint
esbenp.prettier-vscode
golang.go
```

### `dot_local/bin/executable_save-cursor-extensions`

Shell script installed to `~/.local/bin/save-cursor-extensions`. Run manually after adding or removing extensions.

Behavior:
1. Exits with error if `cursor` not in PATH
2. Runs `cursor --list-extensions | sort` → writes `~/.cursor/extensions/list.txt`
3. Prints count of extensions saved

Workflow after running:
```bash
save-cursor-extensions
chezmoi re-add ~/.cursor/extensions/list.txt
cd $(chezmoi source-path) && git add -A && git commit -m "chore: update cursor extensions"
```

### `run_onchange_after_install-cursor-extensions.sh.tmpl`

chezmoi `run_onchange_after_*` script. Automatically triggered by `chezmoi apply` when `list.txt` content changes (via embedded sha256 hash comment).

Behavior:
1. Embeds hash: `# Hash: {{ include "dot_cursor/extensions/list.txt" | sha256sum }}`
2. Skips if `cursor` not in PATH (safe on headless/CI machines)
3. Reads `~/.cursor/extensions/list.txt` line by line
4. Gets currently installed extensions via `cursor --list-extensions`
5. Installs only extensions missing from the current set
6. Idempotent — re-running is safe

## Data Flow

```
[Add extension in Cursor]
        │
        ▼
[Run: save-cursor-extensions]
        │  cursor --list-extensions | sort > ~/.cursor/extensions/list.txt
        ▼
[chezmoi re-add ~/.cursor/extensions/list.txt]
        │
        ▼
[git commit in chezmoi source]
        │
        ▼
[On new machine: chezmoi apply]
        │  list.txt hash changed → triggers run_onchange script
        ▼
[Missing extensions installed via cursor --install-extension]
```

## Conventions Followed

- Matches existing `run_onchange_after_*` pattern (see `run_onchange_after_install-zsh-confd.sh.tmpl`)
- Hash-in-comment trigger pattern matches existing usage
- Export script goes in `dot_local/bin/` alongside `optimize-system.sh`, `local-ai-serve`
- Pure shell, no new runtime dependencies
- `{{- if not .headless }}` guard skips on headless machines where Cursor won't be present
