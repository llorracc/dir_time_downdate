# Makefile for dir-time-downdate
# A tool to update directory timestamps to match their newest content files

# Installation directories
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/share/man
DOCDIR ?= $(PREFIX)/share/doc/dir-time-downdate
SHAREDIR ?= $(PREFIX)/share/dir-time-downdate

# Program name and version
PROGRAM = dir-time-downdate
VERSION := $(shell cat VERSION)

# Source files
SCRIPT = bin/$(PROGRAM)
MANPAGE = man/man1/$(PROGRAM).1
DOCS = README.md LICENSE VERSION
DSSTORE_DIR = dsstore
DOC_FILES = doc/DSSTORE_MANAGEMENT.md

.PHONY: all install uninstall clean test check help install-user install-home install-tools uninstall-home uninstall-user uninstall-tools install-system-config install-tools-system-config uninstall-all uninstall-user-all uninstall-home-all uninstall-tools-all

all: $(SCRIPT) $(MANPAGE)
	@echo "Build complete. Run 'make install' to install."

install: all
	@echo "Installing $(PROGRAM) to $(PREFIX)..."
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 $(SCRIPT) $(DESTDIR)$(BINDIR)/$(PROGRAM)
	@if [ -f $(MANPAGE) ]; then \
		echo "Installing man page..."; \
		install -d $(DESTDIR)$(MANDIR)/man1; \
		install -m 644 $(MANPAGE) $(DESTDIR)$(MANDIR)/man1/; \
	fi
	@echo "Installing documentation..."
	install -d $(DESTDIR)$(DOCDIR)
	install -m 644 $(DOCS) $(DESTDIR)$(DOCDIR)/
	@if [ -d doc ]; then \
		install -d $(DESTDIR)$(DOCDIR)/doc; \
		install -m 644 $(DOC_FILES) $(DESTDIR)$(DOCDIR)/doc/; \
	fi
	@echo "Installing default .DS_Store template..."
	@mkdir -p $(DESTDIR)$(SHAREDIR)/templates
	@if [ -f dsstore/.DS_Store_master ]; then \
		install -m 644 dsstore/.DS_Store_master $(DESTDIR)$(SHAREDIR)/templates/.DS_Store_template; \
		echo "✓ Installed default .DS_Store template to $(SHAREDIR)/templates/.DS_Store_template"; \
	else \
		echo "Warning: Default .DS_Store template not found"; \
	fi
	@echo "Installation complete"
	@echo "You can now run: $(PROGRAM) --help"

uninstall:
	@echo "Uninstalling $(PROGRAM)..."
	rm -f $(DESTDIR)$(BINDIR)/$(PROGRAM)
	rm -f $(DESTDIR)$(MANDIR)/man1/$(PROGRAM).1
	rm -rf $(DESTDIR)$(DOCDIR)
	@echo "Note: Configuration files not removed. Use 'make uninstall-all' to remove configs too."
	@echo "Uninstallation complete."

# Install to user's ~/.local (XDG Base Directory standard)
install-user:
	$(MAKE) install PREFIX=$$HOME/.local SHAREDIR=$$HOME/.local/share/$(PROGRAM)

# Uninstall from user's ~/.local
uninstall-user:
	$(MAKE) uninstall PREFIX=$$HOME/.local

# Install to user's ~/bin (traditional Unix user directory)
install-home:
	@echo "Installing $(PROGRAM) to ~/bin..."
	@mkdir -p $$HOME/bin
	@install -m 755 $(SCRIPT) $$HOME/bin/$(PROGRAM)
	@if [ -f $(MANPAGE) ]; then \
		echo "Installing man page to ~/share/man/man1/..."; \
		mkdir -p $$HOME/share/man/man1; \
		install -m 644 $(MANPAGE) $$HOME/share/man/man1/; \
	fi
	@echo "Installing documentation to ~/share/doc/$(PROGRAM)/..."
	@mkdir -p $$HOME/share/doc/$(PROGRAM)
	@install -m 644 $(DOCS) $$HOME/share/doc/$(PROGRAM)/
	@if [ -d doc ]; then \
		echo "Installing extended documentation..."; \
		mkdir -p $$HOME/share/doc/$(PROGRAM)/doc; \
		install -m 644 $(DOC_FILES) $$HOME/share/doc/$(PROGRAM)/doc/; \
	fi
	@echo "Installing default .DS_Store template to user config..."
	@mkdir -p $$HOME/.config/dir-time-downdate
	@if [ -f dsstore/.DS_Store_master ]; then \
		install -m 644 dsstore/.DS_Store_master $$HOME/.config/dir-time-downdate/.DS_Store_template; \
		echo "# dir-time-downdate user configuration" > $$HOME/.config/dir-time-downdate/config; \
		echo "# Generated on $$(date)" >> $$HOME/.config/dir-time-downdate/config; \
		echo "" >> $$HOME/.config/dir-time-downdate/config; \
		echo "# Default .DS_Store template file path" >> $$HOME/.config/dir-time-downdate/config; \
		echo "DSSTORE_TEMPLATE=$$HOME/.config/dir-time-downdate/.DS_Store_template" >> $$HOME/.config/dir-time-downdate/config; \
		echo "✓ Installed default .DS_Store template and config to ~/.config/dir-time-downdate/"; \
	else \
		echo "Warning: Default .DS_Store template not found"; \
	fi
	@echo "Installation complete"
	@echo "You can now run: $(PROGRAM) --help"
	@if ! echo "$$PATH" | grep -q "$$HOME/bin"; then \
		echo ""; \
		echo "NOTE: $$HOME/bin is not in your PATH."; \
		echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"; \
		echo "  export PATH=\"\$$HOME/bin:\$$PATH\""; \
		echo "Then restart your shell or run: source ~/.bashrc"; \
	fi

# Uninstall from ~/bin
uninstall-home:
	@echo "Uninstalling $(PROGRAM) from ~/bin..."
	@rm -f $$HOME/bin/$(PROGRAM)
	@rm -f $$HOME/share/man/man1/$(PROGRAM).1
	@rm -rf $$HOME/share/doc/$(PROGRAM)
	@echo "Note: Configuration files not removed. Use './uninstall.sh --home --configs-too' for complete removal."
	@echo "Uninstallation complete."

# Install to /opt/tools (alternative system location)
install-tools:
	$(MAKE) install PREFIX=/opt/tools

# Uninstall from /opt/tools
uninstall-tools:
	$(MAKE) uninstall PREFIX=/opt/tools

# Install with system-wide config directory
install-system-config:
	@echo "Installing $(PROGRAM) with system-wide configuration..."
	@./install.sh --system-config

# Install to /opt/tools with system-wide config
install-tools-system-config:
	@echo "Installing $(PROGRAM) to /opt/tools with system-wide configuration..."
	@./install.sh --tools --system-config

# Complete uninstall including all configuration files
uninstall-all:
	@echo "Completely uninstalling $(PROGRAM) and all configuration files..."
	@./uninstall.sh --configs-too

# Complete user uninstall including user configuration files
uninstall-user-all:
	@echo "Completely uninstalling $(PROGRAM) from ~/.local and removing user configs..."
	@./uninstall.sh --user --configs-too --scope user

# Complete home uninstall including user configuration files
uninstall-home-all:
	@echo "Completely uninstalling $(PROGRAM) from ~/bin and removing user configs..."
	@./uninstall.sh --home --configs-too --scope user

# Complete tools uninstall including system configuration files
uninstall-tools-all:
	@echo "Completely uninstalling $(PROGRAM) from /opt/tools and removing system configs..."
	@./uninstall.sh --tools --configs-too

test: $(SCRIPT)
	@echo "Running basic tests..."
	@if ! command -v zsh >/dev/null 2>&1; then \
		echo "Error: zsh not found. This script requires zsh."; \
		exit 1; \
	fi
	@echo "✓ zsh is available"
	@$(SCRIPT) --help >/dev/null && echo "✓ Help command works"
	@echo "✓ Basic tests passed"
	@echo "For full testing, run: make test-full"

test-full: $(SCRIPT)
	@echo "Running comprehensive test suite..."
	@if [ -f tests/test_functionality.sh ]; then \
		chmod +x tests/test_functionality.sh; \
		cd tests && ./test_functionality.sh; \
	else \
		echo "Error: test_functionality.sh not found"; \
		exit 1; \
	fi

test-ci: test-full
	@echo "Running CI-style tests..."
	@echo "Creating test environment..."
	@mkdir -p /tmp/makefile-ci-test/{sub1,sub2}
	@echo "test content 1" > /tmp/makefile-ci-test/file1.txt
	@echo "test content 2" > /tmp/makefile-ci-test/sub1/file2.txt
	@touch /tmp/makefile-ci-test/.DS_Store
	@echo "Running script on test environment..."
	@$(SCRIPT) --verbose --non-interactive /tmp/makefile-ci-test
	@if [ -f /tmp/makefile-ci-test/.DS_Store ]; then \
		echo "ERROR: .DS_Store cleanup failed"; \
		rm -rf /tmp/makefile-ci-test; \
		exit 1; \
	fi
	@rm -rf /tmp/makefile-ci-test
	@echo "✓ CI tests passed"

check: test
	@echo "Running syntax check..."
	@zsh -n $(SCRIPT) && echo "✓ Script syntax is valid"

clean:
	@echo "Nothing to clean (no build artifacts)"

# Create a distributable tarball
dist: clean
	@echo "Creating distribution tarball..."
	@mkdir -p dist
	@tar -czf dist/$(PROGRAM)-$(VERSION).tar.gz \
		--exclude='.git*' \
		--exclude='dist' \
		--exclude='*.tar.gz' \
		--transform 's,^,$(PROGRAM)-$(VERSION)/,' \
		.
	@echo "Created dist/$(PROGRAM)-$(VERSION).tar.gz"

# Install dependencies (if any)
deps:
	@echo "Checking dependencies..."
	@command -v zsh >/dev/null || (echo "zsh is required but not installed"; exit 1)
	@command -v find >/dev/null || (echo "find is required but not installed"; exit 1)
	@command -v stat >/dev/null || (echo "stat is required but not installed"; exit 1)
	@echo "✓ All dependencies satisfied"

help:
	@echo "Available targets:"
	@echo "  all           - Build the program (default)"
	@echo "  install       - Install to $(PREFIX) (may require sudo)"
	@echo "  install-user  - Install to ~/.local (XDG standard)"
	@echo "  install-home  - Install to ~/bin (traditional)"
	@echo "  install-tools - Install to /opt/tools (alternative system)"
	@echo "  uninstall     - Remove from $(PREFIX)"
	@echo "  uninstall-user- Remove from ~/.local"
	@echo "  uninstall-home- Remove from ~/bin"
	@echo "  uninstall-tools- Remove from /opt/tools"
	@echo "  uninstall-all - Complete removal including all config files"
	@echo "  uninstall-user-all - Complete user removal including user configs"
	@echo "  uninstall-home-all - Complete home removal including user configs"
	@echo "  uninstall-tools-all - Complete tools removal including system configs"
	@echo "  test          - Run basic tests"
	@echo "  test-full     - Run comprehensive test suite"
	@echo "  test-ci       - Run CI-style tests (includes cleanup verification)"
	@echo "  check         - Check script syntax"
	@echo "  clean         - Clean build artifacts"
	@echo "  dist          - Create distribution tarball"
	@echo "  deps          - Check dependencies"
	@echo "  help          - Show this help"
	@echo ""
	@echo "Installation options:"
	@echo "  make install       # System-wide: /usr/local/bin (requires sudo)"
	@echo "  make install-user  # User XDG:    ~/.local/bin"
	@echo "  make install-home  # User home:   ~/bin"
	@echo "  make install-tools # Alternative: /opt/tools/bin (requires sudo)"
	@echo ""
	@echo "Installation directories:"
	@echo "  PREFIX=$(PREFIX)"
	@echo "  BINDIR=$(BINDIR)"
	@echo "  MANDIR=$(MANDIR)"
	@echo "  DOCDIR=$(DOCDIR)"
	@echo ""
	@echo "Override with: make install PREFIX=/opt/local" 