# Timestamp Management Script

This directory contains .DS_Store template files that work with the main `dir-time-downdate` utility.

## Purpose

The main `dir-time-downdate` script recursively changes folder timestamps to match the newest file within each directory. This is particularly useful for:

- **Maintaining Logical Timestamps**: Ensuring directory timestamps reflect their most recent content
- **Backup Systems**: Helping backup tools correctly identify recently modified directories
- **File Organization**: Providing visual cues about directory activity in file managers

## Relationship to .DS_Store Management

This directory provides the template files that complement the main script's .DS_Store management capabilities:

- **Before Applying .DS_Store Settings**: Use the main script to normalize directory timestamps across a file hierarchy
- **After System Changes**: Run the script to update parent directory timestamps when files are modified
- **Maintenance Operations**: Periodically run to keep directory timestamps synchronized with content

## Usage Context

While the `.DS_Store` files in this directory maintain specific epoch timestamps for management purposes, the main script addresses the broader need for logical timestamp management across directory structures.

The template files here are automatically used by the main script when the `--create-empty-dsstore` option is specified.

## Access

Run the main script from anywhere after installation:
```bash
dir-time-downdate [options] [target_directory]
```

Or during development:
```bash
./bin/dir-time-downdate [options] [target_directory]
``` 