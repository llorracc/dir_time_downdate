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
./scripts/dir-time-downdate.sh [options] directory...
```

### Options

- `--no-cleanup`: Don't delete .DS_Store files and broken symlinks
- `--non-interactive`: Don't prompt for Finder window closure  
- `--verbose`, `-v`: Show detailed progress
- `--create-empty-dsstore`: Create .DS_Store files with early timestamps
- `--help`, `-h`: Show help

### Examples

```bash
# Basic usage - update directory timestamps
./scripts/dir-time-downdate.sh /path/to/directory

# With .DS_Store creation and verbose output
./scripts/dir-time-downdate.sh --verbose --create-empty-dsstore /path/to/directory

# Non-interactive mode (for scripts)
./scripts/dir-time-downdate.sh --non-interactive --create-empty-dsstore /path/to/directory
```

## Configuration

The master .DS_Store file is located at `config/.DS_Store_master`. You can modify this file to control the content and behavior of all created .DS_Store files when using symlink mode.

## Requirements

- macOS (uses macOS-specific `stat` command format)
- zsh shell
- Optional: GNU find (`gfind`) for enhanced compatibility

## License

MIT License - see LICENSE file for details
