#!/usr/bin/env bash
# Install gh extensions so they are available on new machines.
# Runs once on `chezmoi apply`. Skips extensions that are already installed.

set -euo pipefail

# gh extension list columns: <name> <repo> <version>
EXTENSIONS=(
    "davidraviv/gh-clean-branches"
    "github/gh-copilot"
    "yusukebe/gh-markdown-preview"
    "seachicken/gh-poi"
    "basecamp/gh-signoff"
    "bruxisma/gh-update-branch"
)

if ! command -v gh >/dev/null 2>&1; then
    echo "⚠️  gh is not installed; skipping gh extension setup"
    exit 0
fi

INSTALLED="$(gh extension list 2>/dev/null | awk '{print $2}' || true)"

for ext in "${EXTENSIONS[@]}"; do
    if echo "$INSTALLED" | grep -qx "$ext"; then
        echo "✓ $ext already installed"
    else
        echo "→ installing $ext"
        gh extension install "$ext"
    fi
done
