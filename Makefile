.PHONY: help install test clean

help:
	@echo "Agent Tooling Setup"
	@echo ""
	@echo "Usage:"
	@echo "  make install              Install in current directory"
	@echo "  make install-with-docs    Install with agent-instructions.md"
	@echo "  make test                 Test installation in a temp git repo"
	@echo "  make clean                Remove test artifacts"
	@echo "  make package              Create distributable tarball"
	@echo ""

install:
	@chmod +x install.sh
	@./install.sh

install-with-docs:
	@chmod +x install.sh
	@./install.sh --with-agent-instructions

test:
	@echo "Creating test git repository..."
	@rm -rf /tmp/agent-tooling-test
	@mkdir -p /tmp/agent-tooling-test
	@cd /tmp/agent-tooling-test && git init && git config user.email "test@example.com" && git config user.name "Test User"
	@echo "Running installer..."
	@cd /tmp/agent-tooling-test && bash $(PWD)/install.sh --skip-install
	@echo ""
	@echo "Verifying installation..."
	@cd /tmp/agent-tooling-test && test -f .claude/CLAUDE.md && echo "✓ .claude/CLAUDE.md created"
	@cd /tmp/agent-tooling-test && test -f AGENTS.md && echo "✓ AGENTS.md created"
	@cd /tmp/agent-tooling-test && test -d .beads && echo "✓ .beads directory created"
	@echo ""
	@echo "✓ Test passed!"
	@echo "Test directory: /tmp/agent-tooling-test"

clean:
	@rm -rf /tmp/agent-tooling-test
	@rm -f agent-tooling-setup.tar.gz
	@echo "✓ Cleaned test artifacts"

package: clean
	@echo "Creating distributable package..."
	@tar -czf agent-tooling-setup.tar.gz install.sh uninstall.sh README.md LICENSE Makefile
	@echo "✓ Created agent-tooling-setup.tar.gz"
	@ls -lh agent-tooling-setup.tar.gz
