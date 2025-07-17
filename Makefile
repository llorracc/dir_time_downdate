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
VERSION = 0.1.0

# Source files
SCRIPT = bin/$(PROGRAM)
MANPAGE = man/man1/$(PROGRAM).1
DOCS = README.md LICENSE
DSSTORE_DIR = dsstore
DOC_FILES = doc/DSSTORE_MANAGEMENT.md

.PHONY: all install uninstall clean test check help install-user install-home uninstall-home

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
	@if [ -d $(DSSTORE_DIR) ]; then \
		echo "Installing .DS_Store templates..."; \
		install -d $(DESTDIR)$(SHAREDIR); \
		(cd $(DSSTORE_DIR) && find . -type f -exec install -m 644 {} $(DESTDIR)$(SHAREDIR)/{} \;); \
	fi
	@echo "Installation complete"
	@echo "You can now run: $(PROGRAM) --help"

uninstall:
	@echo "Uninstalling $(PROGRAM)..."
	rm -f $(DESTDIR)$(BINDIR)/$(PROGRAM)
	rm -f $(DESTDIR)$(MANDIR)/man1/$(PROGRAM).1
	rm -rf $(DESTDIR)$(DOCDIR)
	rm -rf $(DESTDIR)$(SHAREDIR)
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
	@if [ -d $(DSSTORE_DIR) ]; then \
		echo "Installing .DS_Store templates to ~/share/$(PROGRAM)/..."; \
		mkdir -p $$HOME/share/$(PROGRAM); \
		(cd $(DSSTORE_DIR) && find . -type f -exec install -m 644 {} $$HOME/share/$(PROGRAM)/{} \;); \
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
	@rm -rf $$HOME/share/$(PROGRAM)
	@echo "Uninstallation complete."

test: $(SCRIPT)
	@echo "Running basic tests..."
	@if ! command -v zsh >/dev/null 2>&1; then \
		echo "Error: zsh not found. This script requires zsh."; \
		exit 1; \
	fi
	@echo "✓ zsh is available"
	@$(SCRIPT) --help >/dev/null && echo "✓ Help command works"
	@echo "✓ Basic tests passed"
	@echo "For full testing, run the script on a test directory"

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
	@echo "  uninstall     - Remove from $(PREFIX)"
	@echo "  uninstall-user- Remove from ~/.local"
	@echo "  uninstall-home- Remove from ~/bin"
	@echo "  test          - Run basic tests"
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
	@echo ""
	@echo "Installation directories:"
	@echo "  PREFIX=$(PREFIX)"
	@echo "  BINDIR=$(BINDIR)"
	@echo "  MANDIR=$(MANDIR)"
	@echo "  DOCDIR=$(DOCDIR)"
	@echo ""
	@echo "Override with: make install PREFIX=/opt/local" 