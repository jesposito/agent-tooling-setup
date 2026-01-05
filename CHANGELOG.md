# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

#### Global Installation Mode
- **`install-global.sh`** - Install once to `~/.agent-tooling/`, use everywhere
- **`agent-tools` CLI wrapper** - Unified interface for all commands
  - `agent-tools init` - Initialize new project
  - `agent-tools doctor` - Run diagnostics
  - `agent-tools update` - Update all tools
  - `agent-tools config` - Edit configuration
- **Per-project overrides** - `.agent-tools.local.yaml` overrides global config
- **Project registry** - Track initialized projects in `~/.agent-tooling/projects/`

#### Diagnostics & Maintenance
- **`agent-tools-doctor.sh`** - Comprehensive health check system
  - Python version detection with Windows compatibility
  - Tool installation verification
  - PATH configuration checks
  - Health scoring (0-100%)
  - Detailed issue reporting with suggestions
  - Optional AI-powered diagnostics (experimental)
- **`agent-tools-update.sh`** - Safe update system
  - Pre-update health checks
  - Automatic timestamped backups
  - Multiple update methods with fallbacks (brew, pip, npm, Go)
  - Post-update validation
  - Rollback capability on failure
  - Backup rotation (keeps last 5)

#### Migration Tools
- **`migrate-mode.sh`** - Switch between installation modes
  - Automatic mode detection (local, global, mixed, none)
  - Dry-run option to preview changes
  - Automatic backups before migration
  - Preserves project-specific files (.beads, .claude, AGENTS.md)
  - Updates .gitignore automatically
  - Project registration/unregistration

#### Configuration System
- **`.agent-tools.yaml.template`** - Comprehensive configuration template
  - Core tools (Beads, Empirica, Perles)
  - Optional AI tools (Mem0, gptme, OpenCommit, Aider, CodeRabbit CLI)
  - Safety settings (all auto-commit features disabled by default)
  - Resource limits and warnings
  - Platform-specific settings
  - Recommended configurations by use case (beginner/intermediate/advanced/team)
- **Tiered installation** - Core, Low Risk, Medium Risk, Advanced
- **Toggle system** - Enable/disable any tool via configuration

#### Expanded Tool Support
- **Mem0** - Universal memory layer for AI agents
  - Optional extras: graph, vector_stores, llms
  - Configurable vector store (Qdrant, ChromaDB, Pinecone, etc.)
- **gptme** - Personal AI assistant in terminal
  - Optional extras: browser, datascience, server, youtube, tts
  - Full shell access with safety considerations
- **OpenCommit** - AI-generated git commit messages
  - Multiple AI providers (OpenAI, Anthropic, Ollama, Gemini, Azure)
  - Conventional commits, gitmoji support
  - Optional git hook (disabled by default)
- **Aider** - AI pair programming
  - Auto-commit disabled by default
  - Safety confirmations
  - Browser extras support
- **CodeRabbit CLI** - AI code review
  - Privacy acknowledgment required
  - Pre-commit review capability

#### Documentation
- **INSTALLATION-MODES.md** - Detailed comparison of global vs per-project modes
- **WINDOWS-NOTES.md** - Windows compatibility guide
  - Compatibility matrix (native vs WSL)
  - Recommended setups
  - Tool-specific limitations
- **ANALYSIS.md** - 10,000+ word deep dive into all tools
  - Tool-by-tool technical analysis
  - Dependencies and requirements
  - Edge cases and conflicts
  - Workflow scenarios
  - Compatibility matrix
- **ENHANCEMENTS-SUMMARY.md** - Feature overview and benefits
- **TESTING-CHECKLIST.md** - Comprehensive testing guide
  - Platform compatibility tests
  - Installation method tests
  - Migration tests
  - Manual testing scenarios
- **SUMMARY.md** - Executive summary of analysis findings

#### Git Integration
- **Auto-managed .gitignore** - Prevents committing sensitive files
  - Installation artifacts
  - API keys and secrets (.env)
  - Cache directories
  - Session files
  - Tool-specific temp files
- **`.gitignore.template`** - Reference template for users

#### Safety & Security
- **All auto-commit features disabled by default**
  - Aider auto-commit: off
  - OpenCommit git hook: opt-in only
  - Manual workflow recommended
- **API key management**
  - Centralized .env file approach
  - .env automatically gitignored
  - Environment variable loading
- **Privacy warnings** for external services (CodeRabbit CLI)
- **Confirmation prompts** for dangerous operations

### Changed

#### Installation Improvements
- **Empirica** - Fixed installation to use GitHub URL instead of non-existent PyPI package
- **Beads** - Added multiple fallback installation methods (brew → Go → npm)
- **Perles** - Added Go fallback installation
- **Python version requirement** - Now recommends 3.10-3.12 (was 3.6+)

#### Documentation Updates
- **README.md** - Updated with global mode, optional tools, diagnostics
- **QUICKSTART.md** - Added global mode instructions and diagnostics commands
- **Requirements section** - Updated with modern Python versions and platform compatibility

#### Test Improvements
- **`.github/workflows/test.yml`** - Fixed test failures
  - Check for `bd` availability before calling `bd init`
  - Create minimal `.beads/` directory when `bd` unavailable
  - Handle `--skip-install` flag correctly

#### Windows Compatibility
- **Python detection** - Fixed `agent-tools-doctor.sh` for Windows
  - Falls back to `python` command if `python3` unavailable
  - Validates version is numeric before parsing
  - Proper error messages

### Fixed

- **Install script** - Fixed Empirica package name (empirica-app → GitHub URL)
- **Beads initialization** - Added check for `bd` before running `bd init`
- **Test workflow** - Create `.beads/` directory even when `bd` not installed
- **Diagnostic script** - Windows compatibility (python3 vs python detection)
- **Documentation links** - Updated all tool URLs to correct repositories

### Security

- **Sensitive file protection** - Auto-managed .gitignore prevents accidental commits
- **API key isolation** - .env file approach with gitignore protection
- **Auto-commit safety** - All auto-commit features disabled by default
- **External service warnings** - Clear warnings for tools that send code externally

## [0.1.0] - Initial Release

### Added

- **Core tool installation** - Beads, Perles, Empirica
- **Basic installer script** - `install.sh`
- **Configuration files**
  - `.claude/CLAUDE.md` - Agent quick reference
  - `AGENTS.md` - Workflow checklist
  - `.gitattributes` - Beads merge strategy
- **Documentation**
  - README.md with workflow examples
  - QUICKSTART.md with 5-minute guide
  - CLAUDE_CODE.md for Claude Code integration
  - CUSTOMIZATION.md for template adaptation
- **GitHub Actions** - Test workflow for CI
- **Claude Code integration** - Direct installation support

### Changed

- N/A (initial release)

### Fixed

- N/A (initial release)

---

## Upgrade Guide

### From 0.1.0 to Unreleased

#### If Using Per-Project Mode

No breaking changes. You can continue using per-project mode as before.

**Optional**: Migrate to global mode for easier maintenance:

```bash
# Download migration script
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/migrate-mode.sh -o migrate-mode.sh
chmod +x migrate-mode.sh

# Preview migration
./migrate-mode.sh to-global --dry-run

# Perform migration
./migrate-mode.sh to-global
```

#### If Starting Fresh

**Recommended**: Use global mode for new projects:

```bash
# Install globally once
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh | bash

# Initialize any project
cd /path/to/your/project
agent-tools init
```

#### Configuration Updates

If you have an existing `.agent-tools.yaml`, review the new template:

```bash
# Download new template
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/.agent-tools.yaml.template -o .agent-tools.yaml.new

# Compare with your config
diff .agent-tools.yaml .agent-tools.yaml.new

# Update as needed
```

#### Python Version

If using Python < 3.10, consider upgrading for full compatibility with optional AI tools:

- Python 3.10-3.12: Full compatibility
- Python 3.6-3.9: Core tools work, some optional tools may not

---

## Version History

- **Unreleased** - Major enhancement: global mode, diagnostics, optional AI tools
- **0.1.0** - Initial release with core tools (Beads, Perles, Empirica)

---

## Semantic Versioning

- **Major version (X.0.0)** - Breaking changes, incompatible API changes
- **Minor version (0.X.0)** - New features, backwards compatible
- **Patch version (0.0.X)** - Bug fixes, backwards compatible

Current status: **Pre-1.0** (API may change between minor versions)
