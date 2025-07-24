# TODO List - dir-time-downdate

## High Priority

### 🌐 Cross-Platform Support for System Files
**Status**: Not Started  
**Priority**: Medium  
**Estimated Effort**: 2-3 hours

Add cross-platform awareness to handle system-generated "junk" files similar to .DS_Store on different operating systems.

**Objective**: Extend the script to automatically detect and appropriately handle OS-specific metadata files that shouldn't affect directory timestamps.

**Details**: See [cross-platform-system-files.md](cross-platform-system-files.md) for comprehensive research and implementation plan.

**Implementation Tasks**:
- [ ] Add OS detection (`uname -s`)
- [ ] Create OS-specific exclusion lists
- [ ] Update file iteration logic to exclude OS-specific files
- [ ] Add command-line option to override OS detection
- [ ] Update documentation with cross-platform examples
- [ ] Test on Linux, macOS, and Windows (WSL)

---

## Medium Priority

### 🕰️ Interactive Timestamp Modification
**Status**: Not Started  
**Priority**: Medium  
**Estimated Effort**: 2-3 hours

Add interactive mode for setting custom timestamps on directories, similar to touch but with user confirmation.

**Objective**: Allow users to set specific timestamps on directories beyond just downgrading to child timestamps.

**Implementation Tasks**:
- [ ] Add `--interactive` or `--set-time` flag
- [ ] Support RFC3339 date format input (2006-01-02T15:04:05Z07:00)
- [ ] Add interactive prompts with confirmation
- [ ] Support relative time adjustments (+/-1day, +/-2hours, etc.)
- [ ] Show current timestamps before modification
- [ ] Add timestamp validation and parsing
- [ ] Update help text and man page

---

### 🔗 Git Integration Features
**Status**: Not Started  
**Priority**: High  
**Estimated Effort**: 3-4 hours

Add Git-aware functionality to reset directory timestamps based on Git commit history.

**Objective**: Integration with Git repositories for build system optimization and reproducible builds.

**Implementation Tasks**:
- [ ] Add `--git-mode` flag to use Git commit timestamps
- [ ] Reset directory timestamps to last commit that modified contents
- [ ] Support for shallow clones with appropriate warnings
- [ ] Integration with CI/CD workflows
- [ ] Add GitHub Actions workflow example
- [ ] Support for Git worktrees and submodules
- [ ] Handle Git-ignored files appropriately

---

### 📋 Timestamp Inspection Mode
**Status**: Not Started  
**Priority**: Low  
**Estimated Effort**: 1 hour

Add read-only mode to display current directory timestamps without modification.

**Objective**: Better debugging and verification capabilities.

**Implementation Tasks**:
- [ ] Add `--inspect` or `--show-timestamps` flag
- [ ] Display current directory modification times
- [ ] Show newest file in each directory
- [ ] Add timestamp comparison analysis
- [ ] Format output for easy reading
- [ ] Support different output formats (table, JSON, etc.)

---

### 🎯 Advanced Pattern Matching
**Status**: Not Started  
**Priority**: Medium  
**Estimated Effort**: 2-3 hours

Extend functionality beyond directories to support file pattern matching and bulk operations.

**Objective**: More flexible timestamp management with file pattern support.

**Implementation Tasks**:
- [ ] Add file pattern matching support (*.jpg, *.pdf, etc.)
- [ ] Support glob patterns and regex matching
- [ ] Bulk operations on matched files
- [ ] Directory and file mixed operations
- [ ] Add exclusion patterns
- [ ] Integration with existing directory logic

---

### 🤖 Remove robots.txt for Public Release
**Status**: Not Started  
**Priority**: Medium  
**Estimated Effort**: 5 minutes

Remove the robots.txt file when the repository is ready for public exposure and search engine indexing.

**Tasks**:
- [ ] Review repository for public readiness
- [ ] Remove robots.txt file from repository root
- [ ] Verify search engines can index the repository

---

### ⚙️ Configuration File Support
**Status**: Not Started  
**Priority**: Medium  
**Estimated Effort**: 2-3 hours

Add support for user configuration files to customize default behavior without command-line options.

**Objective**: Allow users to set personal defaults and custom exclusions via configuration files.

**Details**: See [doc/CONFIGURATION.md](../doc/CONFIGURATION.md) for complete specification.

**Implementation Tasks**:
- [ ] Add configuration file parsing function
- [ ] Search standard XDG config locations
- [ ] Support shell-style KEY=VALUE format
- [ ] Add custom exclusion patterns support
- [ ] Implement colored output and progress indicators
- [ ] Allow custom .DS_Store template paths
- [ ] Ensure command-line options override config file
- [ ] Add configuration validation and error handling
- [ ] Update help text to mention configuration support
- [ ] Add configuration examples to documentation

---

### 🔗 Symlink-based .DS_Store Management
**Status**: Researched  
**Priority**: Medium  
**Estimated Effort**: 1-2 hours

Replace file copying with symlink creation for .DS_Store files to allow centralized content control.

**Tasks**:
- [ ] Modify script to create symlinks instead of copying files
- [ ] Update symlinks to point to master file in config/
- [ ] Set symlink timestamps to Unix epoch
- [ ] Test symlink behavior with Finder
- [ ] Update documentation

---

## Low Priority

### 🎂 Birth Time (Creation Time) Support
**Status**: Not Started  
**Priority**: Low  
**Estimated Effort**: 2-3 hours

Add support for modifying file creation times (birth time) in addition to modification times.

**Objective**: Complete timestamp management including creation time where supported by filesystem.

**Implementation Tasks**:
- [ ] Add macOS birth time support using `SetFile` or native calls
- [ ] Research Linux extended attributes for creation time
- [ ] Add `--birth-time` or `--creation-time` flag
- [ ] Handle filesystems that don't support birth time gracefully
- [ ] Update documentation with filesystem compatibility matrix

---

### 🐳 Container/CI Integration
**Status**: Not Started  
**Priority**: Low  
**Estimated Effort**: 1-2 hours

Add Docker container support and enhanced CI/CD integration.

**Objective**: Better integration with modern DevOps workflows and containerized environments.

**Implementation Tasks**:
- [ ] Create Dockerfile for container deployment
- [ ] Add to GitHub Container Registry
- [ ] Create Docker Compose examples
- [ ] Add Jenkins pipeline examples
- [ ] Support for running in CI environments with appropriate permissions
- [ ] Add container-specific documentation

---

### 📖 Enhanced Documentation
**Status**: Not Started  
**Priority**: Low  
**Estimated Effort**: 1 hour

- [ ] Add man page
- [ ] Create usage examples for common scenarios
- [ ] Add troubleshooting section
- [ ] Document performance considerations for large directory trees

### 🧪 Test Suite
**Status**: Not Started  
**Priority**: Low  
**Estimated Effort**: 3-4 hours

- [ ] Create automated test suite
- [ ] Test edge cases (empty directories, broken symlinks, etc.)
- [ ] Performance benchmarks
- [ ] Cross-platform compatibility tests

### 📦 Package Distribution
**Status**: In Progress  
**Priority**: Medium  
**Estimated Effort**: 2-3 hours

Provide easy installation methods through package managers and distribution platforms.

**Tasks**:
- [x] Create Homebrew formula (see `packaging/homebrew/`)
- [ ] Submit to Homebrew core or create tap
- [ ] Create Debian package (.deb) for Linux compatibility
- [ ] Create RPM package for Red Hat-based distributions
- [ ] Add installation instructions for package managers
- [ ] Set up automated release builds in CI/CD
- [ ] Create release artifacts (tarballs, checksums)

**Future Distribution Methods**:
- [ ] MacPorts portfile
- [ ] Arch User Repository (AUR) package
- [ ] Nix package for NixOS
- [ ] Conda-forge recipe for scientific computing users

---

## Completed

*No completed items yet* 