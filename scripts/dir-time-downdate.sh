#!/usr/bin/env zsh
# https://unix.stackexchange.com/questions/1524/how-do-i-change-folder-timestamps-recursively-to-the-newest-file
# Change directory timestamps recursively to match the newest file within each directory
# This script:
# * Optionally deletes .DS_Store files and broken symlinks first
# * Deletes empty directories after timestamp updates
# * Uses zsh globbing features for efficient file finding

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
CLEANUP_MACOS_FILES=true
INTERACTIVE_MODE=true
VERBOSE=false
CREATE_EMPTY_DSSTORE=false

# Parse command line options
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cleanup)
            CLEANUP_MACOS_FILES=false
            shift
            ;;
        --non-interactive)
            INTERACTIVE_MODE=false
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --create-empty-dsstore)
            CREATE_EMPTY_DSSTORE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options] directory..."
            echo "Options:"
            echo "  --no-cleanup           Don't delete .DS_Store files and broken symlinks"
            echo "  --non-interactive      Don't prompt for Finder window closure"
            echo "  --verbose, -v          Show detailed progress"
            echo "  --create-empty-dsstore Create zero-size .DS_Store files with early timestamps in all directories"
            echo "  --help, -h             Show this help"
            exit 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Check arguments
if [[ $# -eq 0 ]]; then
    echo "Error: No directories specified" >&2
    echo "Usage: $0 [options] directory..." >&2
    exit 1
fi

# Validate directories exist
for dir in "$@"; do
    if [[ ! -d "$dir" ]]; then
        echo "Error: '$dir' is not a directory or does not exist" >&2
        exit 1
    fi
done

# Function to log verbose messages
log_verbose() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo "$@"
    fi
}

# macOS-specific: prompt to close Finder windows (only if Finder is running)
if [[ "$INTERACTIVE_MODE" == "true" && "$OSTYPE" == darwin* ]]; then
    if pgrep -x Finder >/dev/null 2>&1; then
        if command -v say >/dev/null 2>&1; then
            say 'close finder windows' &
        fi
        echo "Finder is running. Close all open Finder windows before running to avoid conflicts."
        echo "Press Enter when ready to continue..."
        read -r
    else
        log_verbose "Finder is not running, proceeding without user prompt."
    fi
fi

# Use appropriate find command (prefer gfind on macOS if available)
FIND_CMD="find"
if command -v gfind >/dev/null 2>&1; then
    FIND_CMD="gfind"
fi

# Cleanup phase
if [[ "$CLEANUP_MACOS_FILES" == "true" ]]; then
    log_verbose "Cleaning up .DS_Store files and broken symlinks..."
    
    for dir in "$@"; do
        # Delete .DS_Store files
        if "$FIND_CMD" "$dir" -name '.DS_Store' -type f -delete 2>/dev/null; then
            log_verbose "Deleted .DS_Store files in $dir"
        fi
        
        # Delete broken symlinks
        if "$FIND_CMD" "$dir" -xtype l -delete 2>/dev/null; then
            log_verbose "Deleted broken symlinks in $dir"
        fi
    done
fi

# Create empty .DS_Store files in all directories (if enabled)
if [[ "$CREATE_EMPTY_DSSTORE" == "true" ]]; then
    log_verbose "Creating empty .DS_Store files in all directories..."
    
    # Use Unix epoch .DS_Store file as template (all timestamps set to epoch 0)
    local source_dsstore="/tmp/test_all_epoch_0/.DS_Store"
    local template_file="/tmp/.dsstore_epoch_template_$$"
    
    if [[ -f "$source_dsstore" ]]; then
        log_verbose "Using Unix epoch .DS_Store file as template (all timestamps: Dec 31 1969)..."
        if cp -p "$source_dsstore" "$template_file" 2>/dev/null; then
            log_verbose "Template created successfully - no system time changes needed"
        else
            echo "Error: Could not copy real .DS_Store template file" >&2
            exit 1
        fi
    else
        echo "Error: Unix epoch .DS_Store template not found at $source_dsstore" >&2
        exit 1
    fi
    
    for dir in "$@"; do
        # Find all directories recursively (do not follow symlinks)
        find "$dir" -type d -not -type l | while IFS= read -r directory; do
            # Skip if directory no longer exists
            [[ -d "$directory" ]] || continue
            
            dsstore_file="$directory/.DS_Store"
            
            # Create zero-size .DS_Store file if it doesn't exist
            if [[ ! -f "$dsstore_file" ]]; then
                # Copy template file preserving ALL epoch 0 timestamps
                if cp -p "$template_file" "$dsstore_file" 2>/dev/null; then
                    log_verbose "Created .DS_Store file in directory: $directory (all timestamps: Dec 31 1969)"
                else
                    echo "Warning: Could not create .DS_Store file in '$directory'" >&2
                fi
            else
                log_verbose "Directory already has .DS_Store file: $directory" 
            fi
        done
    done
    
    # Clean up template file
    rm -f "$template_file" 2>/dev/null
fi

# Main execution
for dir in "$@"; do
    if [[ ! -d "$dir" ]]; then
        echo "Error: '$dir' is not a directory or does not exist" >&2
        exit 1
    fi
    
    log_verbose "Processing directory: $dir"
    
    # Process directories in depth-first order (deepest first), excluding .git directories
    find "$dir" -depth -type d -not -path "*/.git" -not -path "*/.git/*" | while IFS= read -r directory; do
        # Skip if directory no longer exists
        [[ -d "$directory" ]] || continue
        
        # Find the newest file or subdirectory using ls (much faster than find+stat)
        # Use nullglob to handle empty directories gracefully
        setopt local_options nullglob
        newest_file=""
        newest_time=0
        
        # Check regular files and directories
        for item in "$directory"/*; do
            # Skip .git directories (git metadata shouldn't affect directory timestamps)
            [[ "$(basename "$item")" == ".git" ]] && continue
            # Skip .DS_Store files (created by script, shouldn't affect directory timestamps)
            [[ "$(basename "$item")" == ".DS_Store" ]] && continue
            if [[ -e "$item" ]]; then
                if item_time=$(stat -f %m "$item" 2>/dev/null); then
                    if (( item_time > newest_time )); then
                        newest_time=$item_time
                        newest_file="$item"
                    fi
                fi
            fi
        done
        
        # Check hidden files and directories
        for item in "$directory"/.*; do
            # Skip . and .. entries
            [[ "$(basename "$item")" == "." || "$(basename "$item")" == ".." ]] && continue
            # Skip .git directories (git metadata shouldn't affect directory timestamps)
            [[ "$(basename "$item")" == ".git" ]] && continue
            # Skip .DS_Store files (created by script, shouldn't affect directory timestamps)
            [[ "$(basename "$item")" == ".DS_Store" ]] && continue
            if [[ -e "$item" ]]; then
                if item_time=$(stat -f %m "$item" 2>/dev/null); then
                    if (( item_time > newest_time )); then
                        newest_time=$item_time
                        newest_file="$item"
                    fi
                fi
            fi
        done
        
        # Update directory timestamp if we found files
        if [[ -n "$newest_file" && -e "$newest_file" ]]; then
            if touch -r "$newest_file" "$directory" 2>/dev/null; then
                log_verbose "Updated timestamp of '$directory' to match '$newest_file'"
            else
                echo "Warning: Could not update timestamp of '$directory'" >&2
            fi
        else
            log_verbose "Directory '$directory' is empty, leaving timestamp unchanged"
        fi
    done
done

# Final cleanup: remove empty directories (after timestamp updates)
if [[ "$CLEANUP_MACOS_FILES" == "true" ]]; then
    log_verbose "Removing empty directories..."
    for dir in "$@"; do
        # Remove empty directories, but don't remove the target directories themselves
        "$FIND_CMD" "$dir" -mindepth 1 -type d -empty -delete 2>/dev/null && \
            log_verbose "Removed empty directories in $dir"
    done
fi

log_verbose "Directory timestamp update complete." 