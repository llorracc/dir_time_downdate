#!/bin/bash
# Installation script for dir-time-downdate
# A tool to update directory timestamps to match their newest content files

set -e

PROGRAM="dir-time-downdate"
VERSION="0.2.0"

# Default installation prefix
PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
MANDIR="${MANDIR:-$PREFIX/share/man}"
DOCDIR="${DOCDIR:-$PREFIX/share/doc/$PROGRAM}"
SHAREDIR="${SHAREDIR:-$PREFIX/share/$PROGRAM}"

# Configuration options
INSTALL_SYSTEM_CONFIG=false

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
  -h, --help        Show this help message
  --prefix DIR      Install to DIR (default: /usr/local)
  --user            Install to user directory (~/.local)
  --home            Install to ~/bin (traditional user directory)
  --tools           Install to /opt/tools (alternative system location)
  --system-config   Create system-wide config directory (/etc/xdg/dir-time-downdate)

Examples:
  $0                          # Install to /usr/local (requires sudo)
  $0 --user                   # Install to ~/.local
  $0 --home                   # Install to ~/bin
  $0 --tools                  # Install to /opt/tools (requires sudo)
  sudo $0 --prefix=/usr       # Install to /usr
  sudo $0 --system-config     # Install with system-wide config directory

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
    
    info "✓ Installed documentation to $DOCDIR/"
}

# Install default user configuration and template if not already present
install_user_config_and_template() {
    local user_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/dir-time-downdate"
    local user_config_file="$user_config_dir/config"
    local default_template_source="dsstore/.DS_Store_master"
    local default_template_dest="$user_config_dir/.DS_Store_template"

    # Only proceed if the user does not already have a config file
    if [[ -f "$user_config_file" ]]; then
        info "User configuration file already exists. Skipping default template installation."
        return
    fi

    if [[ ! -f "$default_template_source" ]]; then
        warn "Default template source not found. Skipping template installation."
        return
    fi

    info "No user configuration found. Installing default .DS_Store template..."
    
    mkdir -p "$user_config_dir"
    
    cp "$default_template_source" "$default_template_dest"
    chmod 644 "$default_template_dest"
    info "✓ Installed default template to $default_template_dest"

    # Create the config file pointing to the new default template
    cat > "$user_config_file" << EOF
# dir-time-downdate user configuration
# Auto-generated on $(date)
#
# This file was created by the installer to provide a default .DS_Store template.
# You can modify this file to point to a different template or run the command:
# dir-time-downdate --set-template /path/to/your/template

DSSTORE_TEMPLATE="$default_template_dest"
EOF
    chmod 644 "$user_config_file"
    info "✓ Created default user config file: $user_config_file"
}

# Install system-wide configuration directory
install_system_config() {
    if [[ "$INSTALL_SYSTEM_CONFIG" == "true" ]]; then
        info "Installing system-wide configuration directory..."
        
        local system_config_dir="/etc/xdg/dir-time-downdate"
        
        # Create the directory
        mkdir -p "$system_config_dir"
        
        # Install default .DS_Store template
        if [[ -f "dsstore/.DS_Store_master" ]]; then
            cp "dsstore/.DS_Store_master" "$system_config_dir/.DS_Store_template"
            chmod 644 "$system_config_dir/.DS_Store_template"
            info "✓ Installed default .DS_Store template to $system_config_dir/.DS_Store_template"
        else
            warn "Default .DS_Store template not found, skipping template installation"
        fi
        
        # Create a system configuration file pointing to the installed template
        cat > "$system_config_dir/config" << EOF
# dir-time-downdate system-wide configuration
# This file provides default settings for all users
# Users can override these settings in ~/.config/dir-time-downdate/config

# Default .DS_Store template file path
DSSTORE_TEMPLATE=$system_config_dir/.DS_Store_template

# Example: Set a corporate template
# DSSTORE_TEMPLATE=/opt/shared-templates/.DS_Store_corporate
EOF
        
        chmod 644 "$system_config_dir/config"
        
        info "✓ Created system config directory: $system_config_dir"
        info "✓ Created config file with default template: $system_config_dir/config"
        echo
        info "The tool now works out-of-the-box with the default template."
        info "Users can customize with: $PROGRAM --set-template /path/to/custom/template"
    fi
}

# Main installation process
main() {
    echo "Installing $PROGRAM $VERSION"
    echo "Installation prefix: $PREFIX"
    echo
    
    check_dependencies
    install_program
    install_user_config_and_template # Always check for user config
    install_system_config
    
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
        --tools)
            PREFIX="/opt/tools"
            BINDIR="$PREFIX/bin"
            MANDIR="$PREFIX/share/man"
            DOCDIR="$PREFIX/share/doc/$PROGRAM"
            SHAREDIR="$PREFIX/share/$PROGRAM"
            shift
            ;;
        --system-config)
            INSTALL_SYSTEM_CONFIG=true
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