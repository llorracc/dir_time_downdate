# .DS_Store Template Guide for macOS

This guide explains how to find, customize, and use .DS_Store files as templates with `dir-time-downdate`.

## Overview

Starting with version 0.2.0, `dir-time-downdate` requires you to provide your own .DS_Store template file instead of using pre-installed templates. This gives you complete control over Finder behavior and eliminates installation complexity.

## Finding Existing .DS_Store Files

### Quick Discovery
```bash
# Find .DS_Store files in your home directory
find ~ -name ".DS_Store" -type f 2>/dev/null | head -10

# Find .DS_Store files in specific locations
find ~/Documents ~/Desktop ~/Downloads -name ".DS_Store" -type f 2>/dev/null

# Check if current directory has .DS_Store
ls -la .DS_Store 2>/dev/null && echo "Found!" || echo "Not found"
```

### Common Locations
- **Desktop**: `~/Desktop/.DS_Store`
- **Documents**: `~/Documents/.DS_Store`
- **Downloads**: `~/Downloads/.DS_Store`
- **Any folder you've customized in Finder**

## Creating a Custom .DS_Store Template

### Method 1: Customize an Existing Folder

1. **Create or navigate to a test folder**:
   ```bash
   mkdir ~/DS_Store_Template
   cd ~/DS_Store_Template
   
   # Add some sample files
   echo "Sample content" > file1.txt
   echo "More content" > file2.txt
   mkdir subfolder
   ```

2. **Open in Finder and customize**:
   ```bash
   open .
   ```

3. **Customize the view** (this creates/modifies .DS_Store):
   - **View Options** (⌘J): Set icon size, text size, label position
   - **View Mode**: Choose list, icon, column, or gallery view
   - **Sort Order**: By name, date, size, etc.
   - **Icon Arrangement**: Snap to grid, arrange by name, etc.
   - **Background**: Solid color or custom image
   - **Sidebar Width**: Adjust for list view
   - **Column Widths**: Resize columns in list view

4. **Position specific items** (optional):
   - Drag files/folders to specific locations (icon view)
   - This embeds position data in .DS_Store

5. **Copy your template**:
   ```bash
   # Copy to a safe location
   cp .DS_Store ~/my-ds-store-template
   
   # Or copy to project directory
   cp .DS_Store /path/to/your/project/.DS_Store_master
   ```

### Method 2: Start with Minimal Template

Create a basic .DS_Store with just essential settings:

```bash
# Create minimal folder
mkdir ~/minimal-template
cd ~/minimal-template
touch placeholder.txt

# Open and set minimal preferences
open .

# In Finder:
# 1. View → as List (⌘2)
# 2. View → Show View Options (⌘J)
# 3. Set "Sort by: Name"
# 4. Close view options
# 5. Close Finder window

# Copy the minimal template
cp .DS_Store ~/minimal-ds-store-template
```

## Understanding .DS_Store Contents

### What's Stored
- **View preferences**: Icon vs list vs column view
- **Sort preferences**: By name, date, size, kind
- **Icon positions**: Custom positions for files/folders
- **Window geometry**: Size and position of Finder window
- **Background settings**: Color or image
- **Zoom level**: Icon size and text size
- **Column settings**: Width and visibility in list view

### What's NOT Stored
- **File permissions or ownership**
- **File content or metadata**
- **Spotlight comments** (stored in extended attributes)
- **Finder tags** (stored in extended attributes)

## Preparing Templates for `dir-time-downdate`

### Set Early Timestamp (Recommended)
```bash
# Set to Unix epoch (Jan 1, 1970)
touch -t 197001010000 ~/my-ds-store-template

# Or set to a specific early date
touch -t 200001010000 ~/my-ds-store-template  # Year 2000

# Verify timestamp
ls -la ~/my-ds-store-template
```

### Why Early Timestamps?
- **Prevents interference**: Directory timestamp calculations ignore very old files
- **Consistent behavior**: Template doesn't affect "newest file" detection
- **Archive-friendly**: Maintains clean timestamps for backups

## Using Templates with dir-time-downdate

### Basic Usage
```bash
# Works immediately with automatic detection and default template
dir-time-downdate ~/target/directory

# Specify custom template with --template option  
dir-time-downdate --template ~/my-ds-store-template ~/target/directory

# Use environment variable for custom template
export DSSTORE_TEMPLATE=~/my-ds-store-template
dir-time-downdate ~/target/directory
```

### Advanced Symlink Method
```bash
# Create symlinks to your template in target directories
find ~/Projects -type d -exec ln -sf ~/my-ds-store-template {}/.DS_Store \;

# Set symlink timestamps to epoch
find ~/Projects -name ".DS_Store" -type l -exec touch -h -t 197001010000 {} \;

# Then run timestamp updates
dir-time-downdate --verbose ~/Projects
```

## Template Management Strategies

### Single Universal Template
Best for consistent experience across all directories:
```bash
# Create one template for all uses
~/Templates/universal-ds-store
```

### Purpose-Specific Templates
Different templates for different use cases:
```bash
~/Templates/project-ds-store      # Development projects
~/Templates/media-ds-store        # Photos/videos  
~/Templates/document-ds-store     # Text documents
~/Templates/archive-ds-store      # Archived files
```

### Project-Specific Templates
Keep templates with projects:
```bash
~/Projects/MyApp/.DS_Store_template
~/Documents/Reports/.DS_Store_template
```

## Troubleshooting

### Template Not Working
```bash
# Check if template file exists and is readable
ls -la ~/my-ds-store-template
file ~/my-ds-store-template

# Verify it's a valid .DS_Store file
# Should show "Desktop Services Store" or similar
file ~/my-ds-store-template
```

### Finder Not Respecting Template
- **Clear Finder cache**: `sudo find /private/var/folders -name com.apple.dock.iconcache -exec rm {} \;`
- **Restart Finder**: `killall Finder`
- **Log out and back in**: Complete reset of Finder state

### Template File Corruption
```bash
# Test template by copying to test directory
mkdir /tmp/ds-test
cp ~/my-ds-store-template /tmp/ds-test/.DS_Store
open /tmp/ds-test

# If Finder crashes or behaves oddly, template may be corrupt
# Recreate from scratch using Method 1 above
```

## Examples by Use Case

### Software Development
```bash
# Template optimized for code projects
# - List view for easy file scanning
# - Sort by name for predictable order
# - Show file extensions
# - Larger text for readability
```

### Media Management
```bash
# Template optimized for photos/videos
# - Icon view with large thumbnails
# - Sort by date modified
# - Custom background color
# - Snap to grid enabled
```

### Document Archives
```bash
# Template optimized for document storage
# - List view with size and date columns
# - Sort by date modified (newest first)
# - Compact spacing for density
# - Show all file info
```

## Security and Privacy

### .DS_Store Privacy Considerations
- **Contains folder structure**: Names of files and folders
- **Shows usage patterns**: Which views you prefer
- **No file content**: Actual file data is not stored
- **Local metadata only**: Not synced to cloud services by default

### Safe Sharing
```bash
# Remove personal paths before sharing templates
# .DS_Store files may contain absolute paths in some cases
# Always test templates in clean environments before sharing
```

## Integration with Version Control

### Recommended Approach
```bash
# Keep templates in version control
git add .DS_Store_template

# But ignore active .DS_Store files
echo ".DS_Store" >> .gitignore

# Use post-checkout hooks to deploy templates
#!/bin/bash
# .git/hooks/post-checkout
if [ -f .DS_Store_template ]; then
    cp .DS_Store_template .DS_Store
    touch -t 197001010000 .DS_Store
fi
```

This approach gives you complete control over your Finder preferences while maintaining clean project directories. 