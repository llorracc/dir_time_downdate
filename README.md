# dir-time-downdate

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
- `--create-empty-dsstore`: Create .DS_Store files with early timestamps
- `--help`, `-h`: Show help

### Examples

#### Common Scenarios

```bash
# Fix timestamps after cloning a Git repository
# (Git clone sets all files to current time, breaking directory logic)
cd my-cloned-repo
dir-time-downdate --verbose .

# Prepare directory for backup with clean .DS_Store files
dir-time-downdate --create-empty-dsstore --verbose ~/Documents

# Clean up large project directory non-interactively
dir-time-downdate --non-interactive --create-empty-dsstore ~/Projects

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
dir-time-downdate --create-empty-dsstore --non-interactive ./dist
tar -czf project-release.tar.gz ./dist

# Regular maintenance of project directories
dir-time-downdate --non-interactive ~/Development/*/
```

#### Advanced .DS_Store Management

```bash
# Use installed template for centralized .DS_Store management
# (assuming user installation was used)
TEMPLATE_FILE="$HOME/.local/share/dir-time-downdate/.DS_Store_master"

# Deploy to project directories with symlinks
find ~/Projects -type d -maxdepth 2 -exec sh -c '
    ln -sf "$1" "$2/.DS_Store"
    touch -t 197001010000 "$2/.DS_Store"
' _ "$TEMPLATE_FILE" {} \;

# Then run timestamp cleanup
dir-time-downdate --verbose ~/Projects
```

## .DS_Store Management

The tool supports two approaches to .DS_Store file management:

### 1. File Copy Method (Default)
- Creates template-based .DS_Store files in every directory
- Sets timestamps to Unix epoch (1970) to minimize interference
- Simple and independent - each file stands alone

### 2. Symlink-Based Method (Advanced) 
- Uses symbolic links pointing to a master template file
- Enables centralized control of Finder preferences
- Perfect for deploying consistent settings across multiple directories

See `doc/DSSTORE_MANAGEMENT.md` for detailed documentation on both approaches.

### Template Files
Template files are installed to standard system locations:
- **System-wide**: `/usr/local/share/dir-time-downdate/.DS_Store_master`
- **User**: `~/.local/share/dir-time-downdate/.DS_Store_master`
- **Home**: `~/share/dir-time-downdate/.DS_Store_master`

**Important**: The tool only works with properly installed template files. It does not use files from the GitHub repository after installation.

## Installation

### Quick Install (Recommended)
```bash
# System-wide installation (requires sudo)
sudo ./install.sh

# User installation (no sudo required)
./install.sh --user

# Traditional home directory installation  
./install.sh --home
```

### Using Make
```bash
# System-wide installation
sudo make install

# User installation
make install-user

# Home directory installation
make install-home
```

### Manual Installation
1. Copy `bin/dir-time-downdate` to a directory in your PATH (e.g., `/usr/local/bin/`)
2. Copy `dsstore/.DS_Store_master` to `/usr/local/share/dir-time-downdate/.DS_Store_master`
3. Create the directory first: `sudo mkdir -p /usr/local/share/dir-time-downdate/`

**Note**: Manual installation requires copying both the script AND the template files to their proper system locations.

### Uninstallation
```bash
# Remove system-wide installation
sudo ./uninstall.sh

# Remove user installation
./uninstall.sh --user

# Remove home installation
./uninstall.sh --home
```

## Documentation

- **`doc/DSSTORE_MANAGEMENT.md`** - Comprehensive guide to .DS_Store management approaches
- **`man dir-time-downdate`** - Manual page (after installation)
- **`dsstore/README.md`** - Information about the template system

## Important Notes

### Repository Independence
After installation, `dir-time-downdate` operates completely independently of the GitHub repository. You can safely delete the cloned repository directory - the tool will continue to work using the template files installed in system locations.

### Finding Installed Files
To locate your installed template files:
```bash
# System-wide installation
ls -la /usr/local/share/dir-time-downdate/

# User installation  
ls -la ~/.local/share/dir-time-downdate/

# Home installation
ls -la ~/share/dir-time-downdate/
```

## Requirements

- macOS (uses macOS-specific `stat` command format)
- zsh shell
- Optional: GNU find (`gfind`) for enhanced compatibility

## License

MIT License - see LICENSE file for details
