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
