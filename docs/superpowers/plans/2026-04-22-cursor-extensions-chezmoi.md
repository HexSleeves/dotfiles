# Cursor Extensions chezmoi Integration — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Track Cursor extensions in chezmoi and auto-install them on `chezmoi apply`.

**Architecture:** Three files — a plain-text extension list (deployed by chezmoi), a manual export script, and a `run_onchange_after_*` install script that triggers only when the list changes and cursor is available.

**Tech Stack:** bash, chezmoi Go templates, cursor CLI

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `home/dot_cursor/extensions/list.txt` | Create | Tracked extension list, deployed to `~/.cursor/extensions/list.txt` |
| `home/dot_local/bin/executable_save-cursor-extensions` | Create | Export script: `cursor --list-extensions \| sort > list.txt` |
| `home/run_onchange_after_install-cursor-extensions.sh.tmpl` | Create | Install script: runs on `chezmoi apply` when list changes |

---

## Task 1: Create the extension list file

**Files:**
- Create: `home/dot_cursor/extensions/list.txt`

- [ ] **Step 1: Create the directory and file**

```bash
mkdir -p /Users/lecoqjacob/.local/share/chezmoi/home/dot_cursor/extensions
```

- [ ] **Step 2: Write current extensions to the file**

```bash
cursor --list-extensions | sort > /Users/lecoqjacob/.local/share/chezmoi/home/dot_cursor/extensions/list.txt
```

Verify it contains 53 lines:
```bash
wc -l /Users/lecoqjacob/.local/share/chezmoi/home/dot_cursor/extensions/list.txt
```
Expected: `53 ...list.txt`

- [ ] **Step 3: Verify chezmoi sees it**

```bash
chezmoi status
```
Expected: `A  .cursor/extensions/list.txt` (new file to be added)

- [ ] **Step 4: Commit**

```bash
cd /Users/lecoqjacob/.local/share/chezmoi
git add home/dot_cursor/extensions/list.txt
git commit -m "feat: add cursor extension list to chezmoi"
```

---

## Task 2: Create the export script

**Files:**
- Create: `home/dot_local/bin/executable_save-cursor-extensions`

- [ ] **Step 1: Write the export script**

Create `/Users/lecoqjacob/.local/share/chezmoi/home/dot_local/bin/executable_save-cursor-extensions` with this content:

```bash
#!/bin/bash
set -euo pipefail

if ! command -v cursor &>/dev/null; then
    echo "error: cursor not found in PATH" >&2
    exit 1
fi

LIST_FILE="$HOME/.cursor/extensions/list.txt"
mkdir -p "$(dirname "$LIST_FILE")"

cursor --list-extensions | sort > "$LIST_FILE"
COUNT=$(wc -l < "$LIST_FILE" | tr -d ' ')
echo "Saved $COUNT extensions to $LIST_FILE"
```

- [ ] **Step 2: Apply to deploy it**

```bash
chezmoi apply ~/.local/bin/save-cursor-extensions
```

Verify it's executable:
```bash
ls -la ~/.local/bin/save-cursor-extensions
```
Expected: `-rwxr-xr-x ...`

- [ ] **Step 3: Run it to verify it works**

```bash
save-cursor-extensions
```
Expected output: `Saved 53 extensions to /Users/lecoqjacob/.cursor/extensions/list.txt`

- [ ] **Step 4: Commit**

```bash
cd /Users/lecoqjacob/.local/share/chezmoi
git add home/dot_local/bin/executable_save-cursor-extensions
git commit -m "feat: add save-cursor-extensions export script"
```

---

## Task 3: Create the install script

**Files:**
- Create: `home/run_onchange_after_install-cursor-extensions.sh.tmpl`

- [ ] **Step 1: Write the install script**

Create `/Users/lecoqjacob/.local/share/chezmoi/home/run_onchange_after_install-cursor-extensions.sh.tmpl` with this content:

```bash
#!/bin/bash
{{- if not .headless }}
# Hash: {{ include "dot_cursor/extensions/list.txt" | sha256sum }}

set -euo pipefail

if ! command -v cursor &>/dev/null; then
    echo "cursor not in PATH, skipping extension install"
    exit 0
fi

LIST_FILE="$HOME/.cursor/extensions/list.txt"
if [[ ! -f "$LIST_FILE" ]]; then
    echo "No extension list at $LIST_FILE, skipping"
    exit 0
fi

INSTALLED=$(cursor --list-extensions 2>/dev/null)

while IFS= read -r ext; do
    [[ -z "$ext" ]] && continue
    if ! echo "$INSTALLED" | grep -qx "$ext"; then
        echo "Installing $ext..."
        cursor --install-extension "$ext"
    fi
done < "$LIST_FILE"

echo "Cursor extension sync complete"
{{- end }}
```

- [ ] **Step 2: Verify chezmoi renders it without errors**

```bash
chezmoi execute-template < /Users/lecoqjacob/.local/share/chezmoi/home/run_onchange_after_install-cursor-extensions.sh.tmpl
```
Expected: valid bash script with the sha256 hash embedded in the comment (no template errors).

- [ ] **Step 3: Dry-run apply to confirm chezmoi picks it up**

```bash
chezmoi apply --dry-run --verbose 2>&1 | grep -i cursor
```
Expected: shows the run_onchange script will execute.

- [ ] **Step 4: Apply and verify the script runs**

```bash
chezmoi apply
```
Expected: script runs, prints `Cursor extension sync complete` (all already installed, nothing to install on first run).

- [ ] **Step 5: Commit**

```bash
cd /Users/lecoqjacob/.local/share/chezmoi
git add home/run_onchange_after_install-cursor-extensions.sh.tmpl
git commit -m "feat: add run_onchange script to auto-install cursor extensions"
```

---

## Task 4: Verify end-to-end round-trip

- [ ] **Step 1: Simulate adding a new extension to the list**

Add a fake extension ID to the list to test the install trigger:
```bash
echo "fake.extension-test" >> /Users/lecoqjacob/.local/share/chezmoi/home/dot_cursor/extensions/list.txt
```

- [ ] **Step 2: Apply and confirm the script re-runs**

```bash
chezmoi apply 2>&1 | grep -E "Installing|sync complete|fake"
```
Expected: script runs (hash changed) and attempts to install `fake.extension-test`.

- [ ] **Step 3: Revert the test entry**

```bash
# Remove the fake extension
head -n -1 /Users/lecoqjacob/.local/share/chezmoi/home/dot_cursor/extensions/list.txt > /tmp/ext-list.txt
mv /tmp/ext-list.txt /Users/lecoqjacob/.local/share/chezmoi/home/dot_cursor/extensions/list.txt
```

- [ ] **Step 4: Apply again and confirm script re-runs (hash changed again)**

```bash
chezmoi apply 2>&1 | grep -E "sync complete"
```
Expected: `Cursor extension sync complete`

- [ ] **Step 5: Apply a third time and confirm script does NOT re-run**

```bash
chezmoi apply 2>&1 | grep -i cursor || echo "no cursor output (correct — list unchanged)"
```
Expected: `no cursor output (correct — list unchanged)`

- [ ] **Step 6: Final commit to restore clean state**

```bash
cd /Users/lecoqjacob/.local/share/chezmoi
git add home/dot_cursor/extensions/list.txt
git commit -m "chore: restore clean extension list after round-trip test"
```

---

## Workflow Reference (post-implementation)

When you install new extensions in Cursor and want to commit the updated list:

```bash
save-cursor-extensions                      # export current extensions → ~/.cursor/extensions/list.txt
chezmoi re-add ~/.cursor/extensions/list.txt  # sync back to chezmoi source
cd $(chezmoi source-path) && git add home/dot_cursor/extensions/list.txt && git commit -m "chore: update cursor extensions"
```
