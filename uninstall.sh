#!/bin/bash
# Uninstallation script for dir-time-downdate
# Removes all files installed by install.sh

set -e

PROGRAM="dir-time-downdate"
VERSION="0.2.0"

# Default installation prefix (must match install.sh)
PREFIX="${PREFIX:-/usr/local}"
BINDIR="${BINDIR:-$PREFIX/bin}"
MANDIR="${MANDIR:-$PREFIX/share/man}"
DOCDIR="${DOCDIR:-$PREFIX/share/doc/$PROGRAM}"
SHAREDIR="${SHAREDIR:-$PREFIX/share/$PROGRAM}"

# Configuration options
REMOVE_SYSTEM_CONFIG=false
REMOVE_CONFIGS=false
CONFIG_SCOPE="all"  # user, system, or all

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
  -h, --help          Show this help message
  --prefix DIR        Uninstall from DIR (default: /usr/local)
  --user              Uninstall from user directory (~/.local)
  --home              Uninstall from ~/bin (traditional user directory)
  --tools             Uninstall from /opt/tools (alternative system location)
  --system-config     Remove system-wide config directory (/etc/xdg/dir-time-downdate)
  --configs-too       Also remove configuration files
  --scope SCOPE       Which configs to remove: user, system, or all (default: all)
                      Only used with --configs-too
  --dry-run           Show what would be removed without actually removing

Examples:
  $0                          # Uninstall from /usr/local (requires sudo)
  $0 --user                   # Uninstall from ~/.local
  $0 --home                   # Uninstall from ~/bin
  $0 --tools                  # Uninstall from /opt/tools (requires sudo)
  sudo $0 --prefix=/usr       # Uninstall from /usr
  sudo $0 --system-config     # Remove system-wide config directory
  $0 --configs-too            # Remove installation and all config files
  $0 --configs-too --scope user # Remove installation and user config only
  $0 --dry-run --configs-too  # Show what would be removed including configs

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
        # Note: SHAREDIR no longer used - templates are user-provided
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

# Uninstall system-wide configuration directory
uninstall_system_config() {
    local dry_run=${1:-false}
    
    if [[ "$REMOVE_SYSTEM_CONFIG" == "true" ]]; then
        local system_config_dir="/etc/xdg/dir-time-downdate"
        
        if [[ "$dry_run" == "true" ]]; then
            info "DRY RUN - Would remove system configuration:"
            if [[ -d "$system_config_dir" ]]; then
                echo "  - Directory: $system_config_dir"
            else
                echo "  - System config directory not found: $system_config_dir"
            fi
        else
            info "Removing system-wide configuration directory..."
            
            if [[ -d "$system_config_dir" ]]; then
                rm -rf "$system_config_dir"
                info "✓ Removed system config directory: $system_config_dir"
            else
                warn "System config directory not found: $system_config_dir"
            fi
        fi
    fi
}

# Remove user configuration files
remove_user_configs() {
    local dry_run=${1:-false}
    local user_config_dir="$HOME/.config/dir-time-downdate"
    local old_config_file="$HOME/.dir-time-downdate.conf"
    
    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN - Would remove user configuration:"
        if [[ -d "$user_config_dir" ]]; then
            echo "  - Directory: $user_config_dir"
        fi
        if [[ -f "$old_config_file" ]]; then
            echo "  - Legacy config: $old_config_file"
        fi
        if [[ ! -d "$user_config_dir" && ! -f "$old_config_file" ]]; then
            echo "  - No user configuration found"
        fi
    else
        info "Removing user configuration files..."
        
        local removed_something=false
        
        if [[ -d "$user_config_dir" ]]; then
            rm -rf "$user_config_dir"
            info "✓ Removed user config directory: $user_config_dir"
            removed_something=true
        fi
        
        if [[ -f "$old_config_file" ]]; then
            rm -f "$old_config_file"
            info "✓ Removed legacy config file: $old_config_file"
            removed_something=true
        fi
        
        if [[ "$removed_something" == "false" ]]; then
            info "No user configuration files found"
        fi
    fi
}

# Remove system configuration files
remove_system_configs() {
    local dry_run=${1:-false}
    local system_config_dir="/etc/xdg/dir-time-downdate"
    
    if [[ "$dry_run" == "true" ]]; then
        info "DRY RUN - Would remove system configuration:"
        if [[ -d "$system_config_dir" ]]; then
            echo "  - Directory: $system_config_dir"
        else
            echo "  - No system configuration found"
        fi
    else
        info "Removing system configuration files..."
        
        if [[ -d "$system_config_dir" ]]; then
            rm -rf "$system_config_dir"
            info "✓ Removed system config directory: $system_config_dir"
        else
            info "No system configuration directory found"
        fi
    fi
}

# Remove configuration files based on scope
remove_configs() {
    local dry_run=${1:-false}
    
    if [[ "$REMOVE_CONFIGS" == "true" ]]; then
        case "$CONFIG_SCOPE" in
            user)
                remove_user_configs "$dry_run"
                ;;
            system)
                remove_system_configs "$dry_run"
                ;;
            all)
                remove_user_configs "$dry_run"
                remove_system_configs "$dry_run"
                ;;
            *)
                error "Invalid scope: $CONFIG_SCOPE. Must be 'user', 'system', or 'all'"
                exit 1
                ;;
        esac
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
    local dry_run="$DRY_RUN"
    
    echo "Uninstalling $PROGRAM $VERSION"
    echo "Installation prefix: $PREFIX"
    echo
    
    check_installation
    uninstall_program "$dry_run"
    uninstall_system_config "$dry_run"
    remove_configs "$dry_run"
    
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
        --tools)
            PREFIX="/opt/tools"
            BINDIR="$PREFIX/bin"
            MANDIR="$PREFIX/share/man"
            DOCDIR="$PREFIX/share/doc/$PROGRAM"
            SHAREDIR="$PREFIX/share/$PROGRAM"
            shift
            ;;
        --system-config)
            REMOVE_SYSTEM_CONFIG=true
            shift
            ;;
        --configs-too)
            REMOVE_CONFIGS=true
            shift
            ;;
        --scope)
            if [[ -n "$2" ]]; then
                case "$2" in
                    user|system|all)
                        CONFIG_SCOPE="$2"
                        shift 2
                        ;;
                    *)
                        error "Invalid scope: $2. Must be 'user', 'system', or 'all'"
                        exit 1
                        ;;
                esac
            else
                error "--scope requires an argument (user, system, or all)"
                exit 1
            fi
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

# Validate arguments
if [[ "$CONFIG_SCOPE" != "all" && "$REMOVE_CONFIGS" == "false" ]]; then
    warn "--scope specified but --configs-too not set. --scope will be ignored."
fi

# Run main uninstallation
main 