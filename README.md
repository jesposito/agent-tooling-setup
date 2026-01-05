# Agent Tooling Setup

**One-command setup for AI-assisted development**

Integrates powerful tools for working with AI coding agents:

### Core Tools (Always Available)
- 🧠 **Empirica** - Epistemic self-assessment (track what AI knows/learns)
- 📋 **Beads** - Git-backed issue tracker with dependency graphs
- 🎨 **Perles** - Terminal UI with kanban boards and BQL query language

### Optional AI Tools (Toggle On/Off)
- 🧵 **Mem0** - Universal memory layer for AI agents
- 💬 **gptme** - Personal AI assistant in your terminal
- 📝 **OpenCommit** - AI-generated git commit messages
- 🤖 **Aider** - AI pair programming (advanced users)
- 🔍 **CodeRabbit CLI** - AI code review (pre-commit)

See **[agent-tools.yaml.template](agent-tools.yaml.template)** for configuration options and **[.analysis-workspace/ANALYSIS.md](.analysis-workspace/ANALYSIS.md)** for detailed analysis of all tools.

## Quick Start

### Choose Your Installation Mode

**Two installation approaches available:**

1. **Global Mode (Recommended)** - Install once, use everywhere
   - Tools installed to `~/.agent-tooling/`
   - Use across all your projects
   - Unified CLI: `agent-tools` command
   - Centralized configuration with per-project overrides

2. **Per-Project Mode** - Self-contained installation
   - Tools and config in each project
   - Complete isolation per repository
   - Traditional approach

See **[docs/guides/INSTALLATION-MODES.md](docs/guides/INSTALLATION-MODES.md)** for detailed comparison and migration guide.

### Global Installation (Recommended)

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh | bash

# Then in any project:
agent-tools init
```

### Per-Project Installation

```bash
# One-line install
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash
```

### Manual Installation (Per-Project)

```bash
# Clone or download this repository
git clone https://github.com/jesposito/agent-tooling-setup.git
cd agent-tooling-setup

# Make installer executable
chmod +x install.sh

# Run in your project directory
cd /path/to/your/project
/path/to/agent-tooling-setup/install.sh
```

### Installation Options

```bash
# Create agent-instructions.md template
./install.sh --with-agent-instructions

# Skip tool installation (config files only)
./install.sh --skip-install

# Show help
./install.sh --help
```

### 🤖 Using Claude Code? Even Easier!

If you have a Claude Code extension installed in VS Code, just ask:

```
Install the agent tooling setup from https://github.com/jesposito/agent-tooling-setup

Run the installer to set up Empirica, Beads, and Perles for this project.
```

Claude will handle everything automatically!

**Supported Extensions:**
- [Anthropic Claude Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code) (official)
- [Claude Code YOLO](https://marketplace.visualstudio.com/items?itemName=yuanzhixiang.claude-code-yolo) (community)

Both extensions are fully supported with optimized VS Code settings. See **[CLAUDE_CODE.md](CLAUDE_CODE.md)** for full details and example prompts.

## What Gets Installed

### Core Tools (if not already present)

- **bd** (Beads CLI) - Task tracking
- **perles** - Terminal UI
- **empirica** - Epistemic tracking

### Optional AI Tools (Configure in `.agent-tools.yaml`)

- **mem0** - Memory layer (requires vector DB setup)
- **gptme** - Terminal AI agent (with optional extras: browser, datascience, server)
- **opencommit** (oco) - AI commit messages (manual or git hook mode)
- **aider** - AI pair programming (advanced, auto-commits)
- **coderabbit-cli** - AI code review (external service)

**All optional tools are DISABLED by default** for safety. See [agent-tools.yaml.template](agent-tools.yaml.template) for configuration.

### Configuration Files

**Global Mode:**
- `~/.agent-tooling/` - All tools and shared config
- `~/.agent-tooling/config/.agent-tools.yaml` - Global configuration
- Per-project: `.agent-tools.local.yaml` (overrides global config)

**Per-Project Mode:**
- `docs/DEVELOPMENT.md` - Quick reference for agents
- `AGENTS.md` - Workflow and "landing the plane" checklist
- `.gitattributes` - Git merge strategy for Beads
- `.beads/` - Beads database and config
- `.agent-tools.yaml` - Project-specific configuration
- `agent-instructions.md` - Comprehensive development guidelines (optional, use `--with-agent-instructions`)
  - Based on production-tested template
  - Includes customization comments
  - See [docs/guides/CUSTOMIZATION.md](docs/guides/CUSTOMIZATION.md) for adaptation guide

## Integrated Workflow

### Starting a Session

```bash
# Create epistemic tracking session
empirica session-create --ai-id claude-code --output json

# Document what you know
empirica preflight-submit -

# See available work
bd ready
```

### During Development

```bash
# Claim a task
bd update <id> --status in_progress

# Work on code...

# Visualize your board
perles

# Create new tasks as needed
bd create "Task description" --priority P1
```

### Ending a Session

```bash
# Complete tasks
bd close <id>

# Document learnings
empirica postflight-submit -

# Sync with git
bd sync

# Push everything (mandatory!)
git push
```

## Requirements

- Git repository (must be run in a git project)
- **Platform**: macOS, Linux, or Windows (WSL recommended)
  - See **[docs/guides/WINDOWS-NOTES.md](docs/guides/WINDOWS-NOTES.md)** for Windows compatibility
- **Python**: 3.10-3.12 recommended (some tools require modern Python)
- **Optional**: Go 1.16+ (for Beads/Perles from source)
- **Optional**: Node.js 18+ (for OpenCommit if using AI commit messages)

## Diagnostics & Maintenance

### Health Check

```bash
# Run comprehensive diagnostics
./agent-tools-doctor.sh

# Check specific components
./agent-tools-doctor.sh --check-python
./agent-tools-doctor.sh --check-tools

# Generate health report
./agent-tools-doctor.sh --report
```

### Update Tools

```bash
# Update all tools safely
./agent-tools-update.sh

# Update specific tool
./agent-tools-update.sh --tool beads

# Dry run (see what would update)
./agent-tools-update.sh --dry-run
```

**Features:**
- Pre/post update health checks
- Automatic backups before updates
- Rollback capability if issues detected
- Keeps last 5 backups

## Tool Documentation

- **Beads**: https://github.com/steveyegge/beads
- **Perles**: https://github.com/zjrosen/perles
- **Empirica**: https://github.com/Nubaeon/empirica

## Features

### Why Use This?

**Without these tools:**
- ❌ Agents lose context between sessions
- ❌ TODOs scattered in markdown files
- ❌ No dependency tracking
- ❌ Hard to visualize task status

**With this setup:**
- ✅ Persistent memory across sessions (Empirica)
- ✅ Structured task tracking (Beads)
- ✅ Dependency-aware workflow (Beads)
- ✅ Visual kanban boards (Perles)
- ✅ Git-based collaboration
- ✅ Powerful BQL query language

### Example: Perles Kanban Board

```
┌─────────────┬──────────────┬──────────────┬──────────────┐
│   Blocked   │    Ready     │ In Progress  │    Closed    │
├─────────────┼──────────────┼──────────────┼──────────────┤
│ [P0] Fix DB │ [P1] Add API │ [P1] Update  │ [P2] Tests   │
│             │ [P2] Refactor│   docs       │ [P3] Cleanup │
└─────────────┴──────────────┴──────────────┴──────────────┘
```

### Example: BQL Queries

```bql
# Critical open bugs
type = bug and priority = P0 and status = open

# Ready work
status = open and ready = true

# Recent updates
updated >= -24h order by priority

# Epic with all children
type = epic expand down depth *
```

## Usage Tips

### For AI Agents (Claude Code, Cursor, etc.)

**Claude Code users**: Both [Anthropic Claude Code](https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code) and [Claude Code YOLO](https://marketplace.visualstudio.com/items?itemName=yuanzhixiang.claude-code-yolo) are fully supported. See [CLAUDE_CODE.md](CLAUDE_CODE.md) for installation prompts and workflow examples.

This project includes VS Code settings (`.vscode/settings.json`) that automatically configure both extensions with the right context files.

Add this to your agent's context:

```
This project uses Empirica, Beads, and Perles for task management.
See docs/DEVELOPMENT.md for quick reference.
See AGENTS.md for workflow requirements.
```

### For Humans

- Run `perles` to see your task board
- Run `bd ready` to see what's available to work on
- Review `AGENTS.md` for session completion checklist
- Use `bd create` to add tasks for agents

### Customization

This repository includes production-tested templates ready to customize:

- **`agent-instructions.md`** - Comprehensive template with [CUSTOMIZE] markers
  - See [docs/guides/CUSTOMIZATION.md](docs/guides/CUSTOMIZATION.md) for detailed adaptation guide
  - Based on real-world production usage
  - Includes examples for various project types
- `docs/DEVELOPMENT.md` - Agent quick reference (auto-generated by installer)
- `.beads/config.yaml` - Beads configuration
- `.perles/config.yaml` - Perles theme and board layout

**New to this?** Check out [docs/guides/CUSTOMIZATION.md](docs/guides/CUSTOMIZATION.md) for examples of how to adapt the template for:
- Full-stack web apps
- Python data pipelines
- React Native mobile apps
- Your specific project needs

## Uninstalling

```bash
# Remove configuration files
rm -rf .beads docs/DEVELOPMENT.md AGENTS.md

# Remove from git
git rm -r .beads docs/DEVELOPMENT.md AGENTS.md .gitattributes

# Uninstall tools (optional)
brew uninstall bd perles  # macOS
pip uninstall empirica
```

## Troubleshooting

### "Not a git repository"

This installer must be run inside a git repository:

```bash
cd your-project
git init  # if not already a repo
./install.sh
```

### Tools not found after install

Add to your PATH:

```bash
# For Beads/Perles (Go binaries)
export PATH="$HOME/go/bin:$PATH"

# For Empirica (Python)
export PATH="$HOME/.local/bin:$PATH"
```

### Empirica install fails

Install from GitHub:

```bash
pip3 install --user git+https://github.com/Nubaeon/empirica.git
```

## Contributing

This is a template setup. Customize for your workflow!

To create your own version:

1. Fork this repository
2. Modify `install.sh` and templates
3. Update the one-line install URL
4. Share with your team

## License

MIT - Use freely, modify as needed

## Credits

- **Beads** by Steve Yegge
- **Perles** by Zack Rosen
- **Empirica** - Epistemic assessment framework
