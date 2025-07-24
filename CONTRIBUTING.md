# Contributing to dir-time-downdate

Thank you for your interest in contributing to dir-time-downdate! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Code Style](#code-style)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)

## Getting Started

### Prerequisites

- **macOS**: This project is currently macOS-specific (see TODO.md for Linux plans)  
- **zsh**: Version 5.0 or later (default on modern macOS)
- **Standard Unix tools**: `find`, `stat`, `touch` (included with macOS)
- **Optional**: GNU `find` (`gfind`) for enhanced compatibility

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/dir-time-downdate.git
   cd dir-time-downdate
   ```

3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/llorracc/dir_time_downdate.git
   ```

## Development Environment

### Local Testing

1. **Make scripts executable**:
   ```bash
   chmod +x bin/dir-time-downdate tests/test_functionality.sh
   ```

2. **Run basic tests**:
   ```bash
   make test          # Basic functionality
   make test-full     # Comprehensive test suite
   make test-ci       # CI-style tests with cleanup verification
   ```

3. **Test installation**:
   ```bash
   ./install.sh --user    # Install to ~/.local
   ./uninstall.sh --user  # Clean removal
   ```

### Code Quality Checks

- **Syntax validation**: `zsh -n bin/dir-time-downdate`
- **Help functionality**: `./bin/dir-time-downdate --help`
- **Version display**: `./bin/dir-time-downdate --version`

## Code Style

### Shell Script Guidelines

- **Use zsh-specific features** when beneficial (globbing, arrays, etc.)
- **Error handling**: Always use `set -euo pipefail`
- **Quoting**: Quote all variable expansions: `"$variable"`
- **Functions**: Use clear, descriptive function names
- **Comments**: Document complex logic and non-obvious behavior

### Example Code Style

```bash
#!/usr/bin/env zsh
set -euo pipefail

# Function to process directory timestamps
process_directory() {
    local target_dir="$1"
    
    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Directory does not exist: $target_dir" >&2
        return 1
    fi
    
    # Process with verbose logging
    log_verbose "Processing directory: $target_dir"
}
```

### Commit Messages

Follow conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
- `feat: add --dry-run option for preview mode`
- `fix: handle broken symlinks correctly`
- `docs: update installation instructions`
- `test: add edge case for empty directories`

## Testing

### Test Philosophy

- **Comprehensive coverage**: Test normal operation, edge cases, and error conditions
- **Platform-specific**: Focus on macOS behavior and file systems
- **Non-destructive**: Tests should not affect the development environment
- **Reproducible**: Tests should pass consistently on clean macOS systems

### Writing Tests

Tests are located in `tests/test_functionality.sh`. When adding new features:

1. **Add test cases** for new functionality
2. **Test error conditions** and edge cases
3. **Verify cleanup** behavior (especially .DS_Store handling)
4. **Test across macOS versions** if possible

### Running Tests Locally

```bash
# Full test suite
./tests/test_functionality.sh

# Quick CI-style verification
make test-ci

# Individual components
make deps    # Check dependencies
make check   # Syntax validation
```

## Submitting Changes

### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the code style guidelines

3. **Test thoroughly**:
   ```bash
   make test-ci                    # Full CI tests
   ./bin/dir-time-downdate --help  # Manual verification
   ```

4. **Update documentation** if needed:
   - README.md for user-facing changes
   - CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/) format
   - Man page (`man/man1/dir-time-downdate.1`) for new options

5. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add new functionality"
   ```

6. **Push and create PR**:
   ```bash
   git push origin feature/your-feature-name
   ```

### Pull Request Requirements

- ✅ **All tests pass** (CI will verify)
- ✅ **Code follows style guidelines**
- ✅ **Documentation updated** for user-facing changes
- ✅ **CHANGELOG.md updated** with changes
- ✅ **Clear description** of what the PR does
- ✅ **Manual testing** completed on macOS

## Reporting Issues

### Before Reporting

1. **Search existing issues** to avoid duplicates
2. **Test with latest version** from the main branch
3. **Try minimal reproduction** case

### Issue Information

When reporting bugs, please include:

- **macOS version** (e.g., macOS 14.1)
- **zsh version** (`zsh --version`)
- **dir-time-downdate version** (`./bin/dir-time-downdate --version`)
- **Directory structure** being processed (if relevant)
- **Full command** that caused the issue
- **Complete error output**
- **Expected vs actual behavior**

### Feature Requests

For new features:

- **Clear use case**: Why is this needed?
- **Proposed behavior**: How should it work?
- **Alternatives considered**: What other approaches did you consider?
- **macOS compatibility**: Ensure it fits with macOS-first approach

## Development Roadmap

### Current Focus (macOS)

- Improving .DS_Store management approaches
- Enhanced cross-platform system file detection
- Performance optimization for large directory trees

### Future Plans

- **Linux compatibility** (see `TODO/cross-platform-system-files.md`)
- **Windows WSL support** (potential future addition)
- **Enhanced configuration system**
- **Package distribution** (Homebrew, etc.)

## Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Request Reviews**: We provide constructive feedback on contributions

## Recognition

Contributors are recognized in:
- Git commit history
- Release notes in CHANGELOG.md
- GitHub's contributor statistics

Thank you for contributing to dir-time-downdate! 🎉 