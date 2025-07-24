# Configuration System

`dir-time-downdate` uses the XDG Base Directory Specification for configuration management, providing a clean and standards-compliant approach to storing user preferences.

## Configuration Hierarchy

The tool follows a clear priority hierarchy for configuration sources (highest to lowest priority):

1. **Command line options** (`--template PATH`)
2. **Environment variables** (`DSSTORE_TEMPLATE_ENV`)
3. **User configuration** (`~/.config/dir-time-downdate/config`)
4. **System configuration** (`/etc/xdg/dir-time-downdate/config`)

## Configuration Locations

### User Configuration
```
~/.config/dir-time-downdate/config
```
- Personal user settings
- Overrides system-wide defaults
- Created automatically when using `--set-template`

### System Configuration (Optional)
```
/etc/xdg/dir-time-downdate/config
```
- System-wide defaults for all users
- Created only when installed with `--system-config`
- Useful for organizational or corporate defaults

### Legacy Migration
The tool automatically migrates from the old configuration location:
- Old: `~/.dir-time-downdate.conf`
- New: `~/.config/dir-time-downdate/config`

## Configuration Format

Configuration files use simple `KEY=VALUE` format:

```bash
# dir-time-downdate configuration
# Generated on [timestamp]

# Default .DS_Store template file path
DSSTORE_TEMPLATE=/path/to/your/.DS_Store
```

## Template Configuration

### Setting User Templates
```bash
# Set your personal template (saves to user config)
dir-time-downdate --set-template ~/Documents/.DS_Store

# View current configuration
dir-time-downdate --show-template
```

### System-Wide Templates (Administrators)
```bash
# Install with system config support
sudo ./install.sh --system-config

# Edit system config
sudo nano /etc/xdg/dir-time-downdate/config

# Example system config:
# DSSTORE_TEMPLATE=/opt/corporate-templates/.DS_Store_standard
```

## Environment Variables

### DSSTORE_TEMPLATE_ENV
Override template path for the current session:
```bash
# Use specific template for this session only
DSSTORE_TEMPLATE_ENV=/tmp/special-template/.DS_Store dir-time-downdate ~/test
```

### NO_COLOR
Disable colored output:
```bash
# Disable colors
NO_COLOR=1 dir-time-downdate --verbose ~/directory
```

## Configuration Commands

### View Configuration Status
```bash
dir-time-downdate --show-template
```
Shows:
- System configuration status
- User configuration status  
- Environment variables
- Effective configuration being used
- Configuration hierarchy explanation

### Set Template
```bash
# Save template to user configuration
dir-time-downdate --set-template /path/to/.DS_Store
```

### One-Time Template Use
```bash
# Use template without saving to config
dir-time-downdate --template /path/to/.DS_Store ~/target
```

## Example Configurations

### Personal User Setup
```bash
# ~/.config/dir-time-downdate/config
# dir-time-downdate user configuration
# Generated on 2025-07-17 12:00:00

# Default .DS_Store template file path
DSSTORE_TEMPLATE=/Users/john/Templates/finder-settings/.DS_Store
```

### Corporate System Setup
```bash
# /etc/xdg/dir-time-downdate/config
# dir-time-downdate system-wide configuration
# This file provides default settings for all users

# Corporate standard Finder template
DSSTORE_TEMPLATE=/opt/corporate-templates/.DS_Store_standard
```

## Configuration Directory Structure

```
~/.config/dir-time-downdate/
├── config                    # User configuration file
```

```
/etc/xdg/dir-time-downdate/   # System-wide (optional)
├── config                    # System configuration file
```

## Getting Started

### First-Time Setup
1. **Find or create a template**:
   ```bash
   find ~ -name ".DS_Store" -type f | head -5
   ```

2. **Configure your template**:
   ```bash
   dir-time-downdate --set-template ~/Documents/.DS_Store
   ```

3. **Verify configuration**:
   ```bash
   dir-time-downdate --show-template
   ```

4. **Use your template**:
   ```bash
   dir-time-downdate ~/target-directory
   ```

## Template Creation Guide

For detailed instructions on finding and creating .DS_Store templates, see:
- **[DSSTORE_TEMPLATE_GUIDE.md](DSSTORE_TEMPLATE_GUIDE.md)** - Comprehensive template creation guide

## XDG Base Directory Specification

This implementation follows the XDG Base Directory Specification, which provides:
- **Standards compliance**: Follows established Unix/Linux conventions
- **Clean organization**: No clutter in home directory
- **Tool compatibility**: Works well with backup and sync tools
- **Multi-user support**: Clear separation of user and system configs

For more information about XDG, see: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html 