#!/usr/bin/env bash
# Chezmoi Bootstrap Script

set -euo pipefail

# Color output
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export RED='\033[0;31m'
export CYAN='\033[0;36m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

log_info() {
    echo -e "${CYAN}[INFO]${NC} $*"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $*"
}

# Ensure ~/.config/chezmoi/key.txt exists so encrypted files can be decrypted.
ensure_age_key() {
    local key_file="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/key.txt"
    local op_item="Chezmoi Age Key"

    # Already present and looks valid — nothing to do.
    if [[ -s "$key_file" ]] && grep -q "AGE-SECRET-KEY-" "$key_file"; then
        log_info "age key already present at $key_file"
        return 0
    fi

    mkdir -p "$(dirname "$key_file")"

    # Preferred path: pull from 1Password.
    if command -v op >/dev/null 2>&1; then
        if op item get "$op_item" --fields notesPlain >/dev/null 2>&1; then
            log_info "restoring age key from 1Password ($op_item)"
            op item get "$op_item" --fields notesPlain \
                | base64 -d > "$key_file"
            chmod 600 "$key_file"
            if grep -q "AGE-SECRET-KEY-" "$key_file"; then
                log_success "age key restored from 1Password"
                return 0
            fi
            log_error "1Password returned data but it did not decode to a valid age key"
        else
            log_warn "1Password item '$op_item' not accessible (not signed in?)"
        fi
    else
        log_warn "op (1Password CLI) not installed; cannot fetch age key"
    fi

    log_error "age key missing at $key_file and could not be restored."
    echo "  Restore manually:"
    echo "    op item get \"$op_item\" --fields notesPlain | base64 -d > $key_file"
    echo "    chmod 600 $key_file"
    exit 1
}

# Main execution
main() {
    log_info "Starting chezmoi bootstrap"

    # Check if chezmoi is installed
    if ! command -v chezmoi >/dev/null 2>&1; then
        log_error "chezmoi is not installed. Please install it first:"
        echo "  brew install chezmoi"
        exit 1
    fi

    log_info "chezmoi version: $(chezmoi --version)"

    # Ensure the age decryption key is available before any apply/update.
    # Source of truth is the "Chezmoi Age Key" item in 1Password (notesPlain,
    # base64-encoded). The in-repo key.txt.age is only a fallback backup.
    ensure_age_key

    # Check if chezmoi is initialized
    if ! chezmoi source-path >/dev/null 2>&1; then
        log_error "chezmoi is not initialized. Please run:"
        echo "  chezmoi init git@github.com:HexSleeves/dotfiles.git"
        exit 1
    fi

    # Pull and apply latest changes
    log_info "Pulling and applying latest changes from remote"
    chezmoi update

    log_success "Bootstrap completed"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your shell to apply all changes"
    echo "  2. Run 'chezmoi status' to see if there are any unmanaged files"
    echo "  3. Run 'chezmoi managed' to see all managed files"
}

# Run main
main "$@"
