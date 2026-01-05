# Quick Start Guide

## 🤖 Using Claude Code? (10 seconds)

If you have [Claude Code](https://claude.ai/claude-code) installed, just ask:

```
Install the agent tooling setup from https://github.com/jesposito/agent-tooling-setup
```

Done! See [CLAUDE_CODE.md](CLAUDE_CODE.md) for workflow examples. Otherwise, continue below for manual installation.

---

## Choose Installation Mode

**Two approaches available:**

1. **Global Mode** (Recommended) - Install once, use everywhere
2. **Per-Project Mode** - Traditional self-contained install

See [docs/guides/INSTALLATION-MODES.md](docs/guides/INSTALLATION-MODES.md) for detailed comparison.

### Global Installation (Recommended - 60 seconds)

```bash
# 1. Download global installer
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh -o install-global.sh

# 2. Review it (IMPORTANT!)
cat install-global.sh

# 3. Run once to install globally
chmod +x install-global.sh
./install-global.sh

# 4. Initialize in any project
cd /path/to/your/project
agent-tools init
```

**Benefits:**
- Install once, use across all projects
- Unified CLI: `agent-tools doctor`, `agent-tools update`
- Centralized config with per-project overrides
- Easy maintenance

### Per-Project Installation (60 seconds)

```bash
# 1. Download installer
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh -o install.sh

# 2. Review it (IMPORTANT!)
cat install.sh

# 3. Run it in your git project
chmod +x install.sh
./install.sh
```

## First Session (5 minutes)

```bash
# Start epistemic tracking
empirica session-create --ai-id claude-code --output json

# Document what you know
echo "Starting work on [feature]. I know [x, y, z]." | empirica preflight-submit -

# Create your first task
bd create "Implement user authentication" --priority P1

# See what's ready
bd ready

# Start working
bd update <task-id> --status in_progress

# View your board (optional)
perles
```

## During Development

```bash
# Create tasks as you discover work
bd create "Fix login redirect bug" --type bug --priority P0

# Update status
bd update <task-id> --status in_progress

# Add dependencies
bd dep add <child-task> <parent-task>

# Visualize (press ctrl+space to search, ? for help)
perles
```

## End of Session

```bash
# Close completed work
bd close <task-id>

# Document what you learned
echo "Learned: [discovery]. Need to: [follow-up]." | empirica postflight-submit -

# Sync with git
bd sync

# IMPORTANT: Push to remote
git push
```

## Command Reference

### Beads (bd)

| Command | Purpose |
|---------|---------|
| `bd ready` | List unblocked tasks |
| `bd create "Title"` | Create new task |
| `bd show <id>` | View task details |
| `bd update <id> --status in_progress` | Start work |
| `bd close <id>` | Complete task |
| `bd dep add <child> <parent>` | Link tasks |
| `bd sync` | Sync with git |

### Perles

| Key | Action |
|-----|--------|
| `ctrl+space` | Switch Kanban ↔ Search |
| `?` | Show help |
| `j/k` | Navigate |
| `Enter` | View details |
| `/` | Search |
| `a` | Add column |

### Empirica

| Command | Purpose |
|---------|---------|
| `empirica session-create --ai-id <id>` | Start session |
| `empirica preflight-submit -` | Document initial state |
| `empirica postflight-submit -` | Document learnings |

### Diagnostics & Maintenance (Global or Per-Project)

| Command | Purpose |
|---------|---------|
| `agent-tools doctor` (or `./agent-tools-doctor.sh`) | Run health check |
| `agent-tools update` (or `./agent-tools-update.sh`) | Update all tools safely |
| `agent-tools config` | Edit configuration |
| `agent-tools init` | Initialize new project (global mode) |

## BQL Query Examples

Search in Perles with these queries:

```bql
# Critical bugs
type = bug and priority = P0

# Ready work
status = open and ready = true

# Recent updates
updated >= -24h order by priority

# Epic with children
type = epic expand down depth *
```

## Tips

- **Create issues early** - Don't rely on memory
- **Update status often** - Keep board current
- **Document learning** - Future you will thank you
- **Push every session** - See AGENTS.md for checklist
- **Use Perles** - Visualize progress

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Command not found | Add to PATH: `export PATH="$HOME/go/bin:$HOME/.local/bin:$PATH"` |
| Empirica fails | Install: `pip3 install --user git+https://github.com/Nubaeon/empirica.git` |
| Beads not syncing | Run: `bd doctor --fix` |
| Perles won't start | Check: `bd version` (need v0.41.0+) |

## Learn More

- Full docs: See README.md
- Agent workflow: See AGENTS.md (created in your project)
- Configuration: `docs/DEVELOPMENT.md` (created in your project)

## Uninstall

```bash
# Download uninstaller
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/uninstall.sh -o uninstall.sh
chmod +x uninstall.sh

# Review and run
./uninstall.sh --dry-run
./uninstall.sh
```
