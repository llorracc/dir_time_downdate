#!/bin/bash
# Installation script for dir-time-downdate
# A tool to update directory timestamps to match their newest content files

set -e

PROGRAM="dir-time-downdate"
VERSION="0.1.0"

# Default installation prefix
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
Installation script for $PROGRAM

Usage: $0 [OPTIONS]

Options:
  -h, --help    Show this help message
  --prefix DIR  Install to DIR (default: /usr/local)
  --user        Install to user directory (~/.local)
  --home        Install to ~/bin (traditional user directory)

Examples:
  $0                    # Install to /usr/local (requires sudo)
  $0 --user             # Install to ~/.local
  $0 --home             # Install to ~/bin
  sudo $0 --prefix=/usr # Install to /usr

EOF
}

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command -v zsh >/dev/null 2>&1; then
        missing_deps+=("zsh")
    fi
    
    if ! command -v find >/dev/null 2>&1; then
        missing_deps+=("find")
    fi
    
    if ! command -v stat >/dev/null 2>&1; then
        missing_deps+=("stat")
    fi
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
    
    info "✓ All dependencies satisfied"
}

# Install the program
install_program() {
    info "Installing $PROGRAM to $PREFIX..."
    
    # Create directories
    mkdir -p "$BINDIR" "$MANDIR/man1" "$DOCDIR" "$SHAREDIR"
    
    # Install binary
    if [[ -f "bin/$PROGRAM" ]]; then
        cp "bin/$PROGRAM" "$BINDIR/$PROGRAM"
        chmod 755 "$BINDIR/$PROGRAM"
        info "✓ Installed binary to $BINDIR/$PROGRAM"
    else
        error "Source file bin/$PROGRAM not found"
        exit 1
    fi
    
    # Install man page
    if [[ -f "man/man1/$PROGRAM.1" ]]; then
        cp "man/man1/$PROGRAM.1" "$MANDIR/man1/"
        chmod 644 "$MANDIR/man1/$PROGRAM.1"
        info "✓ Installed man page to $MANDIR/man1/$PROGRAM.1"
    else
        warn "Man page not found, skipping"
    fi
    
    # Install documentation
    for doc in README.md LICENSE; do
        if [[ -f "$doc" ]]; then
            cp "$doc" "$DOCDIR/"
            chmod 644 "$DOCDIR/$doc"
        fi
    done
    
    # Install extended documentation
    if [[ -d "doc" ]]; then
        mkdir -p "$DOCDIR/doc"
        cp -r doc/* "$DOCDIR/doc/"
        chmod -R 644 "$DOCDIR/doc/"*
        info "✓ Installed extended documentation to $DOCDIR/doc/"
    fi
    
    # Install .DS_Store template files to share directory (program data)
    if [[ -d "dsstore" ]]; then
        # Copy all files including hidden ones
        (cd dsstore && cp -r . "$SHAREDIR/")
        # Set proper permissions: 644 for files, 755 for directories
        find "$SHAREDIR" -type f -exec chmod 644 {} \;
        find "$SHAREDIR" -type d -exec chmod 755 {} \;
        info "✓ Installed .DS_Store templates to $SHAREDIR/"
    fi
    
    info "✓ Installed documentation to $DOCDIR/"
}

# Main installation process
main() {
    echo "Installing $PROGRAM $VERSION"
    echo "Installation prefix: $PREFIX"
    echo
    
    check_dependencies
    install_program
    
    echo
    info "Installation complete"
    echo "You can now run: $PROGRAM --help"
    
    # Check if PATH setup is needed
    if [[ "$BINDIR" == "$HOME/bin" ]]; then
        if ! echo "$PATH" | grep -q "$HOME/bin"; then
            echo
            warn "NOTE: $HOME/bin is not in your PATH."
            echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
            echo "  export PATH=\"\$HOME/bin:\$PATH\""
            echo "Then restart your shell or run: source ~/.bashrc"
        fi
    elif [[ "$PREFIX" != "/usr/local" ]] && [[ "$PREFIX" != "/usr" ]]; then
        echo
        warn "Note: You may need to add $BINDIR to your PATH:"
        echo "  export PATH=\"$BINDIR:\$PATH\""
    fi
}

# Parse command line arguments
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
        *)
            error "Unknown option: $1"
            echo "Use --help for usage information."
            exit 1
            ;;
    esac
done

# Run main installation
main 