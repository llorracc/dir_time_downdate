#!/bin/bash
# Uninstallation script for dir-time-downdate
# Removes all files installed by install.sh

set -e

PROGRAM="dir-time-downdate"
VERSION="0.1.0"

# Default installation prefix (must match install.sh)
PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
MANDIR="${MANDIR:-$PREFIX/share/man}"
DOCDIR="${DOCDIR:-$PREFIX/share/doc/$PROGRAM}"
SHAREDIR="${SHAREDIR:-$PREFIX/share/$PROGRAM}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Show help
show_help() {
    cat << EOF
Uninstallation script for $PROGRAM

Usage: $0 [OPTIONS]

Options:
  -h, --help    Show this help message
  --prefix DIR  Uninstall from DIR (default: /usr/local)
  --user        Uninstall from user directory (~/.local)
  --home        Uninstall from ~/bin (traditional user directory)
  --dry-run     Show what would be removed without actually removing

Examples:
  $0                    # Uninstall from /usr/local (requires sudo)
  $0 --user             # Uninstall from ~/.local
  $0 --home             # Uninstall from ~/bin
  sudo $0 --prefix=/usr # Uninstall from /usr

EOF
}

# Uninstall the program
uninstall_program() {
    local dry_run=${1:-false}
    
    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN - Would remove the following files:"
    else
        info "Uninstalling $PROGRAM from $PREFIX..."
    fi
    
    local files_to_remove=(
        "$BINDIR/$PROGRAM"
        "$MANDIR/man1/$PROGRAM.1"
    )
    
    local dirs_to_remove=(
        "$DOCDIR"
        "$SHAREDIR"
    )
    
    # Remove individual files
    for file in "${files_to_remove[@]}"; do
        if [[ -f "$file" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                echo "  - File: $file"
            else
                rm -f "$file"
                info "✓ Removed $file"
            fi
        fi
    done
    
    # Remove directories
    for dir in "${dirs_to_remove[@]}"; do
        if [[ -d "$dir" ]]; then
            if [[ "$dry_run" == "true" ]]; then
                echo "  - Directory: $dir"
            else
                rm -rf "$dir"
                info "✓ Removed directory $dir"
            fi
        fi
    done
    
    if [[ "$dry_run" != "true" ]]; then
        info "Uninstallation complete"
    fi
}

# Check if anything is installed
check_installation() {
    local found=false
    
    if [[ -f "$BINDIR/$PROGRAM" ]]; then
        found=true
    fi
    
    if [[ -f "$MANDIR/man1/$PROGRAM.1" ]]; then
        found=true
    fi
    
    if [[ -d "$DOCDIR" ]]; then
        found=true
    fi
    
    if [[ -d "$SHAREDIR" ]]; then
        found=true
    fi
    
    if [[ "$found" == "false" ]]; then
        warn "$PROGRAM does not appear to be installed in $PREFIX"
        echo "Check these locations manually if needed:"
        echo "  $BINDIR/$PROGRAM"
        echo "  $MANDIR/man1/$PROGRAM.1"
        echo "  $DOCDIR"
        echo "  $SHAREDIR"
        exit 1
    fi
}

# Main uninstallation process
main() {
    local dry_run=false
    
    echo "Uninstalling $PROGRAM $VERSION"
    echo "Installation prefix: $PREFIX"
    echo
    
    # Parse dry-run flag if passed
    if [[ "${1:-}" == "--dry-run" ]]; then
        dry_run=true
        shift
    fi
    
    check_installation
    uninstall_program "$dry_run"
    
    if [[ "$dry_run" != "true" ]]; then
        echo
        info "You may want to run 'hash -r' or restart your shell to clear cached paths."
    fi
}

# Parse command line arguments
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        --prefix)
            PREFIX="$2"
            BINDIR="$PREFIX/bin"
            MANDIR="$PREFIX/share/man"
            DOCDIR="$PREFIX/share/doc/$PROGRAM"
            SHAREDIR="$PREFIX/share/$PROGRAM"
            shift 2
            ;;
        --user)
            PREFIX="$HOME/.local"
            BINDIR="$PREFIX/bin"
            MANDIR="$PREFIX/share/man"
            DOCDIR="$PREFIX/share/doc/$PROGRAM"
            SHAREDIR="$PREFIX/share/$PROGRAM"
            shift
            ;;
        --home)
            PREFIX="$HOME"
            BINDIR="$HOME/bin"
            MANDIR="$HOME/share/man"
            DOCDIR="$HOME/share/doc/$PROGRAM"
            SHAREDIR="$HOME/share/$PROGRAM"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        *)
            error "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Run main uninstallation
main "$DRY_RUN" 