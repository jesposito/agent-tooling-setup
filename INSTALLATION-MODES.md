# Agent Tooling Installation Modes

The agent-tooling-setup supports two installation modes to fit different workflows:

1. **Per-Project Mode** - Traditional approach, tools installed in each project
2. **Global Mode** - Install once, use across all projects ⭐ **RECOMMENDED**

---

## 🌍 Global Mode (Recommended)

**Best for:**
- Working on multiple projects
- Keeping project directories clean
- Easier updates (update once, affects all projects)
- Team environments (shared installation location)

### How it works

```
~/.agent-tooling/              # Global installation
├── bin/                       # Tool binaries (bd, empirica, perles, etc.)
├── lib/                       # Installed packages
├── config/
│   └── .agent-tools.yaml      # Global defaults
└── projects/                  # Per-project state
    ├── project-a/
    │   ├── .beads/            # Project-specific beads
    │   └── empirica/          # Project-specific sessions
    └── project-b/
        ├── .beads/
        └── empirica/

your-project/                  # Your actual project
├── .agent-tools.link          # Symlink to global config
├── .claude/CLAUDE.md          # Agent instructions (committed)
├── AGENTS.md                  # Workflow docs (committed)
└── ... (your code)
```

### Installation

```bash
# Install globally (run anywhere)
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh | bash

# Or clone and run
git clone https://github.com/jesposito/agent-tooling-setup.git ~/.agent-tooling-installer
~/.agent-tooling-installer/install-global.sh
```

### Initialize a project

```bash
# In your project directory
cd ~/projects/my-app
agent-tools init

# This creates:
# - .claude/CLAUDE.md
# - AGENTS.md
# - .agent-tools.link -> ~/.agent-tooling/projects/my-app
# - Adds entries to .gitignore
```

### Usage

```bash
# Tools are available system-wide
cd ~/projects/any-project
bd ready                        # Uses beads for this project
empirica session-create         # Creates session for this project
perles                          # Shows kanban for this project

# Tools automatically detect current git repo
```

### Benefits

✅ Install once, use everywhere
✅ Easier updates (`agent-tools update`)
✅ Clean project directories
✅ Shared configuration with per-project overrides
✅ Faster new project setup
✅ Better for teams (standard location)

### Drawbacks

⚠️ Requires global installation permissions
⚠️ Less portable (projects depend on global install)
⚠️ Need to initialize each new project

---

## 📁 Per-Project Mode (Traditional)

**Best for:**
- Single project focus
- Self-contained repositories
- When you can't install globally
- Experimentation / testing

### How it works

```
your-project/
├── .beads/                    # Beads database
├── .claude/CLAUDE.md          # Agent instructions
├── AGENTS.md                  # Workflow docs
├── .agent-tools/              # Local installation
│   ├── venv/                  # Python virtual environment
│   └── node_modules/          # Node.js packages
├── .agent-tools.yaml          # Configuration
└── ... (your code)
```

### Installation

```bash
# In your project directory
cd ~/projects/my-app
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash

# Or clone and run
git clone https://github.com/jesposito/agent-tooling-setup.git /tmp/agent-tooling
/tmp/agent-tooling/install.sh
```

### Usage

```bash
# Tools are available in this project only
cd ~/projects/my-app
bd ready
empirica session-create
perles
```

### Benefits

✅ Self-contained (no external dependencies)
✅ Portable (clone repo, everything is there)
✅ Per-project tool versions
✅ No global permissions needed
✅ Easy to uninstall (just delete `.agent-tools/`)

### Drawbacks

⚠️ Must install in each project
⚠️ Larger repository size
⚠️ Updates require updating each project
⚠️ More files in project directory

---

## 🔄 Comparison

| Feature | Global Mode | Per-Project Mode |
|---------|-------------|------------------|
| **Installation** | Once | Per project |
| **Updates** | Once | Each project |
| **Disk usage** | Low per project | High per project |
| **Project setup** | `agent-tools init` | Full install |
| **Portability** | Depends on global | Fully portable |
| **Team use** | Standard location | Self-contained |
| **Clean repo** | ✅ Very clean | ⚠️ More files |
| **Requirements** | Global permissions | Local only |

---

## 🔀 Switching Modes

### From Per-Project to Global

```bash
# 1. Install globally
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh | bash

# 2. Migrate each project
cd ~/projects/my-app
agent-tools migrate-to-global

# This will:
# - Move .beads/ to ~/.agent-tooling/projects/my-app/.beads/
# - Remove .agent-tools/ directory
# - Create .agent-tools.link
# - Update .gitignore
# - Keep AGENTS.md, .claude/CLAUDE.md
```

### From Global to Per-Project

```bash
# In your project directory
cd ~/projects/my-app
agent-tools migrate-to-local

# This will:
# - Copy .beads/ from ~/.agent-tooling/projects/my-app/
# - Install tools locally to .agent-tools/
# - Remove .agent-tools.link
# - Update .gitignore
```

---

## 🎯 Recommended Setup

### For Most Users: Global Mode

```bash
# 1. One-time global install
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh | bash

# 2. Configure once
agent-tools configure

# 3. Initialize each project as needed
cd ~/projects/project-1 && agent-tools init
cd ~/projects/project-2 && agent-tools init
cd ~/projects/project-3 && agent-tools init

# 4. Use anywhere
cd ~/projects/any-project
bd ready
```

### For Experimental/Testing: Per-Project Mode

```bash
# Quick test in a new project
mkdir test-project && cd test-project
git init
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash
```

---

## 📋 Project-Specific vs Global Configuration

### Global Configuration
**Location:** `~/.agent-tooling/config/.agent-tools.yaml`

Contains defaults for all projects:
```yaml
# Global defaults
ai_tools:
  opencommit:
    enabled: true
    config:
      ai_provider: "openai"
      model: "gpt-4o-mini"
```

### Per-Project Override
**Location:** `your-project/.agent-tools.yaml`

Overrides global settings for this project:
```yaml
# Project-specific overrides
ai_tools:
  opencommit:
    config:
      model: "gpt-4o"  # Use better model for this project

  aider:
    enabled: true      # Enable only for this project
```

### Resolution Order
1. Per-project `.agent-tools.yaml` (highest priority)
2. Global `~/.agent-tooling/config/.agent-tools.yaml`
3. Built-in defaults (lowest priority)

---

## 🛠️ Global Mode: Advanced Features

### Project Detection

Tools automatically detect which project you're in:

```bash
# Works from any subdirectory
cd ~/projects/my-app/src/components
bd ready                    # Shows beads for my-app

cd ~/projects/other-app/tests
bd ready                    # Shows beads for other-app
```

### Project State Storage

```
~/.agent-tooling/projects/
├── my-app-1a2b3c4d/        # Hashed by git repo root
│   ├── .beads/
│   ├── empirica/
│   │   └── sessions/
│   └── metadata.json
└── other-app-5e6f7g8h/
    └── .beads/
```

### Shared Tools, Isolated Data

- **Shared:** Tool binaries, libraries, global config
- **Isolated:** Beads database, Empirica sessions, project config

---

## ❓ FAQ

**Q: Can I use both modes?**
A: Not simultaneously for the same project, but you can use global mode for some projects and per-project mode for others.

**Q: What happens to my beads if I switch modes?**
A: The migration scripts preserve all data (beads, sessions, config).

**Q: Can multiple users share a global install?**
A: Yes, install to a shared location (e.g., `/opt/agent-tooling/`) and ensure all users have appropriate permissions.

**Q: What if I work on a server?**
A: Global mode works great on servers. Install to `~/.agent-tooling/` and use across all your server projects.

**Q: How do I update tools in global mode?**
A: `agent-tools update` updates all tools once for all projects.

**Q: How do I uninstall?**
A:
- Global: `agent-tools uninstall-global` (removes everything)
- Per-project: `./uninstall.sh` in project directory

**Q: What about CI/CD?**
A: Per-project mode is better for CI/CD (self-contained). Or install tools in CI environment and use global mode.

---

## 🚀 Quick Start Guide

### Option 1: Global Mode (Recommended)

```bash
# Install once
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh | bash

# Use in any project
cd ~/projects/my-app
agent-tools init
bd create "First task"
bd ready
```

### Option 2: Per-Project Mode

```bash
# Install in project
cd ~/projects/my-app
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash

# Use in this project
bd create "First task"
bd ready
```

---

**Choose the mode that fits your workflow!**

Most users will prefer **Global Mode** for its convenience and clean project directories.
