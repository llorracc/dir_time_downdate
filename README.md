# dir-time-downdate

[![CI](https://github.com/llorracc/dir_time_downdate/actions/workflows/ci.yml/badge.svg)](https://github.com/llorracc/dir_time_downdate/actions/workflows/ci.yml)
[![Quick Tests](https://github.com/llorracc/dir_time_downdate/actions/workflows/test-quick.yml/badge.svg)](https://github.com/llorracc/dir_time_downdate/actions/workflows/test-quick.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-zsh-green.svg)](https://www.zsh.org/)

A utility to recursively update directory timestamps to match their newest content files, with optional .DS_Store management.

## Features

- Updates directory modification times to reflect their actual newest content
- Optionally creates .DS_Store files with early timestamps (Unix epoch)
- Supports both file copying and symlink-based .DS_Store management
- Excludes git metadata and other system files from timestamp calculations
- Cleans up empty directories and broken symlinks

## Usage

```bash
# After installation:
dir-time-downdate [options] directory...

# During development:
./bin/dir-time-downdate [options] directory...
```

### Options

- `--no-cleanup`: Don't delete .DS_Store files and broken symlinks
- `--non-interactive`: Don't prompt for Finder window closure  
- `--verbose`, `-v`: Show detailed progress
- **Automatic .DS_Store management**: Detects macOS or existing .DS_Store files and manages them automatically
- `--help`, `-h`: Show help

### Examples

#### Common Scenarios

```bash
# Fix timestamps after cloning a Git repository
# (Git clone sets all files to current time, breaking directory logic)
cd my-cloned-repo
dir-time-downdate --verbose .

# Prepare directory for backup with clean .DS_Store files
dir-time-downdate --verbose ~/Documents

# Clean up large project directory non-interactively
dir-time-downdate --non-interactive ~/Projects

# Process multiple directories at once
dir-time-downdate --verbose ~/Documents ~/Pictures ~/Music
```

#### Development Workflow

```bash
# After git clone (timestamps are all wrong)
git clone https://github.com/user/project.git
cd project
dir-time-downdate --verbose .

# Before creating archive for distribution
dir-time-downdate --non-interactive ./dist
tar -czf project-release.tar.gz ./dist

# Regular maintenance of project directories
dir-time-downdate --non-interactive ~/Development/*/
```

#### Advanced .DS_Store Management

```bash
# Works automatically - detects macOS or existing .DS_Store files
dir-time-downdate ~/Projects

# Optional: Set up your custom .DS_Store template
dir-time-downdate --set-template ~/Documents/.DS_Store

# Verify configuration
dir-time-downdate --show-template

# Deploy to project directories with symlinks (advanced)
TEMPLATE_FILE="$HOME/Documents/.DS_Store"
find ~/Projects -type d -maxdepth 2 -exec sh -c '
    ln -sf "$1" "$2/.DS_Store"
    touch -t 197001010000 "$2/.DS_Store"
' _ "$TEMPLATE_FILE" {} \;

# Then run timestamp cleanup
dir-time-downdate --verbose ~/Projects
```

## .DS_Store Management

The tool provides **automatic .DS_Store management** that detects when it's needed (macOS or existing .DS_Store files) and uses an included default template. You can customize with your own templates:

### Template Configuration
- **Automatic operation** - Works immediately after installation, no flags needed
- **`--set-template PATH`** - Save a custom .DS_Store file as your default template  
- **`--show-template`** - View current template configuration
- **`--template PATH`** - Use a specific template for one-time operations

### Configuration Storage
Templates follow the XDG Base Directory Specification with a configuration hierarchy:

**System-wide config (lowest priority):**
```
/etc/xdg/dir-time-downdate/config
```

**User config (higher priority, overrides system):**
```
~/.config/dir-time-downdate/config
```

This provides clean home directory organization while supporting both system-wide defaults and user customization.

### Template Methods
1. **File Copy Method** (Default)
   - Creates template-based .DS_Store files in every directory
   - Sets timestamps to Unix epoch (1970) to minimize interference
   - Simple and independent - each file stands alone

2. **Symlink-Based Method** (Advanced) 
   - Uses symbolic links pointing to a master template file
   - Enables centralized control of Finder preferences
   - Perfect for deploying consistent settings across multiple directories

### System-Wide Configuration (For Administrators)
When installed with `--system-config`, administrators can provide default templates:

```bash
# Install with system config support
sudo ./install.sh --system-config

# Edit system config to set organization-wide template
sudo nano /etc/xdg/dir-time-downdate/config

# Example system config content:
# DSSTORE_TEMPLATE=/opt/corporate-templates/.DS_Store_standard
```

**Configuration Hierarchy:**
1. Command line (`--template PATH`) - highest priority
2. Environment variable (`DSSTORE_TEMPLATE_ENV`)
3. User config (`~/.config/dir-time-downdate/config`) - overrides system
4. System config (`/etc/xdg/dir-time-downdate/config`) - lowest priority

### Getting Started with Templates

**Quick Start (works immediately):**
```bash
dir-time-downdate ~/YourProject
```

**Custom Templates:**
See **`doc/DSSTORE_TEMPLATE_GUIDE.md`** for comprehensive instructions on:
- Finding existing .DS_Store files on your system
- Creating custom templates with specific Finder preferences
- Customizing the default template system

## Installation

### System-Wide Installation (Recommended for Multi-User Systems)

For Unix systems where you want the tool available to all users while keeping it separate from system packages:

```bash
# Install to /usr/local/ (requires sudo)
sudo ./install.sh

# Install with system-wide config directory (optional)
sudo ./install.sh --system-config
```

**Why `/usr/local/`?**
- **`/usr/local/bin/`** - Standard location for administrator-installed executables
- **Separate from system packages** - Avoids conflicts with package managers that use `/usr/bin/`
- **Automatically in PATH** - All users can run the tool without configuration
- **Follows Unix standards** - Complies with Filesystem Hierarchy Standard (FHS)

**Installation Layout:**
```
/usr/local/bin/dir-time-downdate                    # Executable
/usr/local/share/man/man1/dir-time-downdate.1       # Manual page
/usr/local/share/doc/dir-time-downdate/             # Documentation
/etc/xdg/dir-time-downdate/config                   # System config (optional)
```

**Alternative Tools Location (`--tools`):**
```
/opt/tools/bin/dir-time-downdate                    # Executable
/opt/tools/share/man/man1/dir-time-downdate.1       # Manual page
/opt/tools/share/doc/dir-time-downdate/             # Documentation
/etc/xdg/dir-time-downdate/config                   # System config (optional)
```

### Alternative Installation Methods

```bash
# User installation (no sudo required)
./install.sh --user

# Traditional home directory installation  
./install.sh --home

# Alternative tools location (requires sudo)
sudo ./install.sh --tools
```

### Using Make
```bash
# System-wide installation
sudo make install

# User installation
make install-user

# Home directory installation
make install-home

# Tools installation
sudo make install-tools

# System installation with system-wide config
sudo make install-system-config

# Tools installation with system-wide config
sudo make install-tools-system-config
```

### Manual Installation
1. Copy `bin/dir-time-downdate` to a directory in your PATH (e.g., `/usr/local/bin/`)
2. Make it executable: `chmod +x /usr/local/bin/dir-time-downdate`

**Note**: The tool includes a default .DS_Store template for immediate use, with optional customization available.

## Related Tools

Several other tools exist for directory timestamp management with overlapping but distinct functionality:

### [mtimedir](https://github.com/itchyny/mtimedir) by itchyny
- **Complementary functionality**: Updates directory timestamps to the **newest** file timestamp (opposite direction)
- **Language**: Go
- **Use case**: When you want directories to reflect their most recent content changes
- **Relationship**: Perfect complement to `dir-time-downdate` - between these two tools, you can sync directories in either direction

### [dirt](https://github.com/c-blake/bu) by c-blake  
- **Same functionality**: Also updates directory timestamps to the **oldest** file timestamp
- **Language**: Nim
- **Difference**: Part of a larger "bu" (Basic Utilities) collection with 60+ tools, not a standalone utility
- **Use case**: Identical to `dir-time-downdate`
- **Relationship**: Functional equivalent, but `dir-time-downdate` offers standalone installation, comprehensive documentation, and repository independence

### Key Differentiators
- **`dir-time-downdate`**: Standalone tool, comprehensive installation system, repository-independent operation, macOS .DS_Store integration
- **`mtimedir`**: Opposite direction (newest vs oldest), lightweight Go implementation, cross-platform
- **`dirt`**: Same direction but requires installing entire utility collection

**Practical Combination**: Use `dir-time-downdate` for preparing directories for archival/backup (oldest timestamps) and `mtimedir` for reflecting active development (newest timestamps). Together they provide bi-directional directory timestamp synchronization.

### Uninstallation
```bash
# Remove system-wide installation
sudo ./uninstall.sh

# Remove tools installation
sudo ./uninstall.sh --tools

# Remove user installation
./uninstall.sh --user

# Remove home installation
./uninstall.sh --home
```

## Documentation

- **`doc/DSSTORE_TEMPLATE_GUIDE.md`** - Comprehensive guide to finding and creating .DS_Store templates
- **`doc/DSSTORE_MANAGEMENT.md`** - Advanced .DS_Store management approaches
- **`man dir-time-downdate`** - Manual page (after installation)
- **`dsstore/README.md`** - Information about .DS_Store files

## Important Notes

### Repository Independence
After installation, `dir-time-downdate` operates completely independently of the GitHub repository. You can safely delete the cloned repository directory - the tool will continue to work using your configured template files.

### Configuration Location
Your template configuration is stored at:
```bash
# View your configuration
cat ~/.config/dir-time-downdate/config

# Check configuration status
dir-time-downdate --show-template
```

## Requirements

- **macOS** (uses macOS-specific `stat` command format)
- **zsh shell** (version 5.0 or later, included with modern macOS)
- **Optional**: GNU find (`gfind`) for enhanced compatibility

### Shell Compatibility

This tool is specifically designed for **zsh** and uses zsh-specific features:
- Advanced globbing patterns for efficient file discovery
- Local array variables for processing file lists
- Zsh-specific parameter expansion and string manipulation

### Platform Compatibility

**Currently Supported:**
- ✅ **macOS 10.15+** (Catalina and later with default zsh)
- ✅ **macOS 11+** (Big Sur and later - fully tested)

**Planned Support:**
- 🔄 **Linux** with zsh (see [TODO.md](TODO/TODO.md) for roadmap)
- 🔄 **Windows WSL** with zsh (future consideration)

**Not Supported:**
- ❌ bash (uses zsh-specific syntax)
- ❌ Pure POSIX shell (requires zsh features)
- ❌ Native Windows (PowerShell/cmd.exe)

> **Note**: This tool is currently macOS-specific. Linux compatibility is planned for a future release (see [TODO.md](TODO/TODO.md) for details).

## License

MIT License - see LICENSE file for details

## Credits

This repository was created by Christopher Carroll using Cursor with Claude Sonnet 4 as the backend AI on 2025-01-22.
