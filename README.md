# Agent Tooling Setup

**One-command setup for AI-assisted development**

Integrates three powerful tools for working with AI coding agents:

- 🧠 **Empirica** - Epistemic self-assessment (track what AI knows/learns)
- 📋 **Beads** - Git-backed issue tracker with dependency graphs
- 🎨 **Perles** - Terminal UI with kanban boards and BQL query language

## Quick Start

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash
```

### Manual Installation

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

If you have [Claude Code](https://claude.ai/claude-code) installed in VS Code, just ask:

```
Install the agent tooling setup from https://github.com/jesposito/agent-tooling-setup

Run the installer to set up Empirica, Beads, and Perles for this project.
```

Claude will handle everything automatically! See **[CLAUDE_CODE.md](CLAUDE_CODE.md)** for full details and example prompts.

## What Gets Installed

### Tools (if not already present)

- **bd** (Beads CLI) - Task tracking
- **perles** - Terminal UI
- **empirica** - Epistemic tracking

### Configuration Files

- `.claude/CLAUDE.md` - Quick reference for agents
- `AGENTS.md` - Workflow and "landing the plane" checklist
- `.gitattributes` - Git merge strategy for Beads
- `.beads/` - Beads database and config
- `agent-instructions.md` - Comprehensive development guidelines (optional, use `--with-agent-instructions`)
  - Based on production-tested template
  - Includes customization comments
  - See [CUSTOMIZATION.md](CUSTOMIZATION.md) for adaptation guide

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
- macOS or Linux
- For Empirica: Python 3.6+ with pip

## Tool Documentation

- **Beads**: https://github.com/steveyegge/beads
- **Perles**: https://github.com/zjrosen/perles
- **Empirica**: https://pypi.org/project/empirica-app/

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

**Claude Code users**: See [CLAUDE_CODE.md](CLAUDE_CODE.md) for installation prompts and workflow examples.

Add this to your agent's context:

```
This project uses Empirica, Beads, and Perles for task management.
See .claude/CLAUDE.md for quick reference.
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
  - See [CUSTOMIZATION.md](CUSTOMIZATION.md) for detailed adaptation guide
  - Based on real-world production usage
  - Includes examples for various project types
- `.claude/CLAUDE.md` - Agent quick reference (auto-generated by installer)
- `.beads/config.yaml` - Beads configuration
- `.perles/config.yaml` - Perles theme and board layout

**New to this?** Check out [CUSTOMIZATION.md](CUSTOMIZATION.md) for examples of how to adapt the template for:
- Full-stack web apps
- Python data pipelines
- React Native mobile apps
- Your specific project needs

## Uninstalling

```bash
# Remove configuration files
rm -rf .beads .claude/CLAUDE.md AGENTS.md

# Remove from git
git rm -r .beads .claude/CLAUDE.md AGENTS.md .gitattributes

# Uninstall tools (optional)
brew uninstall bd perles  # macOS
pip uninstall empirica-app
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

Install Python dependencies:

```bash
pip3 install --user empirica-app
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
