# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CI/CD pipeline with GitHub Actions (macOS-focused testing)
- `--version` flag to display version information
- VERSION file for centralized version management
- Issue and pull request templates
- Comprehensive test suite integration with CI
- Status badges in README
- **Enhanced UX**: Colored output with `--no-color` option
- **Configuration documentation**: Complete configuration system specification
- **Git attributes**: Proper line ending and file type handling
- **Package distribution**: Homebrew formula for easy installation
- **Enhanced logging**: Color-coded log levels (INFO, SUCCESS, WARNING, ERROR)
- **Progress indicators**: Verbose mode shows progress for long operations
- **Configuration cleanup**: New uninstall options for complete removal
  - `--configs-too` flag to remove configuration files during uninstall
  - `--scope` parameter to control which configs to remove (user, system, or all)
  - New Makefile targets: `uninstall-all`, `uninstall-user-all`, `uninstall-home-all`, `uninstall-tools-all`
  - Proper dry-run support for configuration removal
  - Removes both XDG config (`~/.config/dir-time-downdate/`) and legacy config (`~/.dir-time-downdate.conf`)

### Changed
- Enhanced Makefile with new test targets (`test-full`, `test-ci`)
- Updated README with CI status badges and improved formatting
- **Improved error messages**: Color-coded error output with consistent formatting
- **Better platform documentation**: Clear zsh requirement and compatibility matrix
- **Comprehensive .gitignore overhaul**: Complete rewrite with extensive documentation and patterns for:
  - Project-specific patterns (.specstory/, prompts/, prompts_local/, caches)
  - Cross-platform system files (macOS, Windows, Linux)
  - IDE and editor files (VS Code, JetBrains, Vim, Emacs, Sublime)
  - Build and distribution artifacts
  - Security and credential files
  - Shell script development patterns
  - Man page generation artifacts
  - Package management caches
- **Repository cleanup**: Automatically untracked previously committed files that should be ignored

### Fixed
- Improved error handling and user feedback
- Consistent color output that respects NO_COLOR environment variable
- Better terminal detection for color output

## [0.2.0] - 2025-07-17

### Added
- **User-provided template system**: Complete architectural change from system-installed to user-provided templates
  - Template configuration commands (`--set-template`, `--show-template`, `--template`)
  - Persistent template configuration with automatic loading
  - Comprehensive template guide (`doc/DSSTORE_TEMPLATE_GUIDE.md`)
  - Simplified installation (executable only, no template files)
- **XDG Base Directory compliance**: Moved configuration from `~/.dir-time-downdate.conf` to `~/.config/dir-time-downdate/config`
  - Automatic migration from old config location
  - Follows XDG Base Directory Specification for clean home directory organization
  - Created config directory automatically when needed
  - **System-wide configuration support**: Added `/etc/xdg/dir-time-downdate/config` for system-wide defaults
  - Configuration hierarchy: command line > environment > user config > system config
  - New installation option: `--system-config` to create system-wide config directory
  - Enhanced `--show-template` display showing all configuration sources and hierarchy
  - New Makefile targets: `install-system-config`, `install-tools-system-config`

### Changed
- **BREAKING**: Removed system-installed template files - users must provide their own templates
- **BREAKING**: Configuration location moved to XDG-compliant `~/.config/dir-time-downdate/config`
- Updated all documentation to reflect user-provided template system
- Simplified installation scripts (no longer install template files)
- Updated man page with comprehensive new functionality documentation

## [0.1.0] - 2025-01-XX

### Added
- Initial release of dir-time-downdate utility
- Recursive directory timestamp updating functionality
- .DS_Store file management (creation and cleanup)
- Multiple installation methods (system-wide, user, home)
- Comprehensive command-line options
- Man page documentation
- Makefile-based build system
- Basic test suite
- Cross-platform system file handling (macOS focus)
- Interactive and non-interactive modes
- Verbose logging capability

### Features
- Updates directory modification times to match newest content
- Optional .DS_Store file creation with Unix epoch timestamps
- Symlink and file-based .DS_Store management approaches
- Git metadata exclusion from timestamp calculations
- Empty directory and broken symlink cleanup
- Template-based .DS_Store deployment
- Multi-directory batch processing

### Documentation
- Comprehensive README with usage examples
- Man page with full command reference
- Installation and uninstallation guides
- Advanced .DS_Store management documentation

[Unreleased]: https://github.com/llorracc/dir_time_downdate/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/llorracc/dir_time_downdate/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/llorracc/dir_time_downdate/releases/tag/v0.1.0 