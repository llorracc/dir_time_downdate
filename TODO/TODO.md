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

---

## Completed

*No completed items yet* 