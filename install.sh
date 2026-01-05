#!/usr/bin/env bash
set -e

# Agent Tooling Setup Installer
# Installs and configures Empirica + Beads + Perles for AI-assisted development

VERSION="1.0.0"
REPO_URL="https://github.com/steveyegge/beads"
PERLES_URL="https://github.com/zjrosen/perles"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not a git repository. Please run this in a git project."
    fi
    success "Git repository detected"
}

# Check if tool is installed
check_installed() {
    if command -v "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Install Beads (bd)
install_beads() {
    if check_installed bd; then
        success "Beads already installed ($(bd version))"
        return
    fi

    info "Installing Beads..."

    # Try different installation methods
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if check_installed brew; then
            brew tap steveyegge/beads 2>/dev/null || true
            brew install steveyegge/beads/bd || {
                warn "Homebrew install failed, trying install script..."
                curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
            }
        else
            curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
        fi
    else
        # Linux or other
        curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
    fi

    # If still not installed, try Go as a fallback
    if ! check_installed bd && check_installed go; then
        warn "Trying Go installation as fallback..."
        go install github.com/steveyegge/beads/cmd/bd@latest
    fi

    # If still not installed, try npm as a fallback
    if ! check_installed bd && check_installed npm; then
        warn "Trying npm installation as fallback..."
        npm install -g @beads/bd
    fi

    if check_installed bd; then
        success "Beads installed successfully"
    else
        error "Failed to install Beads. Please install manually from $REPO_URL"
        echo "  Try: go install github.com/steveyegge/beads/cmd/bd@latest"
        echo "  Or: npm install -g @beads/bd"
        exit 1
    fi
}

# Install Perles
install_perles() {
    if check_installed perles; then
        success "Perles already installed ($(perles --version | head -1))"
        return
    fi

    info "Installing Perles..."

    # Try different installation methods
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if check_installed brew; then
            brew tap zjrosen/perles 2>/dev/null || true
            brew install perles || {
                warn "Homebrew install failed, trying install script..."
                curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash
            }
        else
            curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash
        fi
    else
        # Linux or other
        curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash
    fi

    # If still not installed, try Go as a fallback (requires Go 1.21+)
    if ! check_installed perles && check_installed go; then
        warn "Trying Go installation as fallback..."
        go install github.com/zjrosen/perles@latest
    fi

    if check_installed perles; then
        success "Perles installed successfully"
    else
        warn "Failed to install Perles. You can install manually from $PERLES_URL"
        warn "  Try: go install github.com/zjrosen/perles@latest"
        warn "Continuing without Perles (optional component)..."
    fi
}

# Install Empirica
install_empirica() {
    if check_installed empirica; then
        success "Empirica already installed ($(empirica --version | head -1))"
        return
    fi

    info "Installing Empirica..."

    if check_installed pip3; then
        pip3 install --user git+https://github.com/Nubaeon/empirica.git || pip install --user git+https://github.com/Nubaeon/empirica.git || {
            warn "Failed to install Empirica via pip"
            warn "You can install manually: pip install git+https://github.com/Nubaeon/empirica.git"
            warn "Continuing without Empirica (optional component)..."
            return
        }
        success "Empirica installed successfully"
    else
        warn "pip3 not found. Please install Python 3 and pip to use Empirica."
        warn "Continuing without Empirica (optional component)..."
    fi
}

# Initialize Beads in current project
init_beads() {
    if [ -d ".beads" ]; then
        warn "Beads already initialized in this project"
        return
    fi

    if ! check_installed bd; then
        warn "Beads (bd) not installed, skipping initialization"
        warn "Run 'bd init' manually after installing Beads"
        return
    fi

    info "Initializing Beads..."
    bd init || error "Failed to initialize Beads"
    success "Beads initialized"
}

# Create .claude directory if it doesn't exist
setup_claude_dir() {
    if [ ! -d ".claude" ]; then
        mkdir -p .claude
        success "Created .claude directory"
    fi
}

# Get project name from git or directory
get_project_name() {
    # Try to get from git remote
    local remote_url=$(git config --get remote.origin.url 2>/dev/null || echo "")
    if [ -n "$remote_url" ]; then
        # Extract repo name from URL
        basename "$remote_url" .git
    else
        # Fall back to directory name
        basename "$(pwd)"
    fi
}

# Copy/create template files
setup_templates() {
    local project_name=$(get_project_name)

    info "Setting up configuration files..."

    # Create CLAUDE.md if it doesn't exist
    if [ ! -f ".claude/CLAUDE.md" ]; then
        cat > .claude/CLAUDE.md << 'EOF'
# Agent Tooling - Integrated Development Environment

This project uses three integrated tools for AI-assisted development:

## 🧠 Empirica - Epistemic Self-Assessment
Track what you know and learn throughout development sessions.

```bash
# Start session
empirica session-create --ai-id claude-code --output json

# Before work: What do I know?
empirica preflight-submit -

# After work: What did I learn?
empirica postflight-submit -
```

## 📋 Beads (bd) - Task & Issue Tracking
Distributed, git-backed graph issue tracker for structured task management.

```bash
# Find available work
bd ready

# View issue details
bd show <id>

# Claim work
bd update <id> --status in_progress

# Complete work
bd close <id>

# Sync with git
bd sync
```

## 🎨 Perles - Visual Task Management
Terminal UI for Beads with kanban boards and BQL query language.

```bash
# Launch TUI
perles

# Switch between Kanban and Search
ctrl+space

# View help
?
```

## 🔄 Integrated Workflow

1. **Session Start**
   - Run `empirica session-create` to begin tracking
   - Run `empirica preflight-submit -` to document initial knowledge
   - Run `bd ready` to identify available tasks

2. **During Development**
   - Use `bd` commands to track task progress
   - Use `perles` to visualize and manage kanban board
   - Update issue status as work progresses

3. **Session End**
   - Run `empirica postflight-submit -` to document learnings
   - Run `bd sync` to synchronize issues with git
   - See [AGENTS.md](../AGENTS.md) for mandatory landing-the-plane workflow

See [agent-instructions.md](../agent-instructions.md) for complete development guidelines (if present).
EOF
        success "Created .claude/CLAUDE.md"
    else
        warn ".claude/CLAUDE.md already exists, skipping"
    fi

    # AGENTS.md is created by bd init, so we don't need to create it

    # Optionally create a basic agent-instructions.md if requested
    if [ "$CREATE_AGENT_INSTRUCTIONS" = "true" ] && [ ! -f "agent-instructions.md" ]; then
        cat > agent-instructions.md << 'EOF'
# Agent Instructions

This document contains guidelines for AI agents working on this project.

## Integrated Agent Tooling

This project uses three integrated tools for enhanced AI-assisted development:

### 🧠 Empirica - Epistemic Tracking
**Purpose**: Track what you know and learn to avoid redundant investigation and maintain context.

**Workflow**:
- **Session Start**: `empirica session-create --ai-id claude-code --output json`
- **Before Work**: `empirica preflight-submit -` - Document current knowledge state
- **After Work**: `empirica postflight-submit -` - Document learnings and discoveries

### 📋 Beads (bd) - Task Management
**Purpose**: Replace TODO comments and markdown checklists with a git-backed dependency graph.

**Workflow**:
- **Find Work**: `bd ready` - List unblocked tasks
- **View Details**: `bd show <id>` - See task context and dependencies
- **Claim Work**: `bd update <id> --status in_progress`
- **Complete**: `bd close <id>`
- **Sync**: `bd sync` - Sync with git (part of landing-the-plane)

**Integration Points**:
- Use `bd` instead of TODO comments in code
- Create issues during planning for incomplete work
- Track tasks as beads with dependencies

### 🎨 Perles - Visual Management
**Purpose**: Kanban board and search interface for Beads.

**Usage**:
- Launch: `perles`
- Switch modes: `ctrl+space` (Kanban ↔ Search)
- Use BQL queries to filter issues
- Visualize dependency trees

### 🔄 Integrated Development Cycle

```
START SESSION
│
├─ empirica session-create
├─ empirica preflight-submit -
└─ bd ready
   │
   ├─ SELECT TASK from ready list
   ├─ bd update <id> --status in_progress
   │
   DEVELOPMENT LOOP
   │
   ├─ Work on tasks
   ├─ Update bd status as work progresses
   ├─ Create new beads for discovered work
   └─ Use perles for visualization
      │
      END SESSION (Landing the Plane)
      │
      ├─ bd close <completed-ids>
      ├─ bd sync
      ├─ empirica postflight-submit -
      └─ git push (see AGENTS.md)
```

## Project-Specific Guidelines

Add your project-specific guidelines here...

EOF
        success "Created agent-instructions.md template"
    fi
}

# Main installation flow
main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   Agent Tooling Setup v${VERSION}                    ║"
    echo "║   Empirica + Beads + Perles Integration               ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --with-agent-instructions)
                CREATE_AGENT_INSTRUCTIONS=true
                shift
                ;;
            --skip-install)
                SKIP_INSTALL=true
                shift
                ;;
            --help)
                echo "Usage: install.sh [options]"
                echo ""
                echo "Options:"
                echo "  --with-agent-instructions  Create agent-instructions.md template"
                echo "  --skip-install            Skip tool installation, only setup config"
                echo "  --help                    Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                ;;
        esac
    done

    check_git_repo

    if [ "$SKIP_INSTALL" != "true" ]; then
        info "Installing tools..."
        install_beads
        install_perles
        install_empirica
        echo ""
    fi

    info "Setting up project..."
    init_beads
    setup_claude_dir
    setup_templates

    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   ✓ Installation Complete!                            ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    success "Agent tooling is now configured for this project"
    echo ""
    info "Next steps:"
    echo "  1. Review configuration in .claude/CLAUDE.md"
    echo "  2. Review workflow in AGENTS.md"
    echo "  3. Start a session: empirica session-create --ai-id claude-code --output json"
    echo "  4. Create your first task: bd create 'Task description'"
    echo "  5. View your board: perles"
    echo ""
    info "Add .beads/ to your git repository:"
    echo "  git add .beads/ .claude/CLAUDE.md AGENTS.md .gitattributes"
    echo "  git commit -m 'Add agent tooling setup'"
    echo ""
}

main "$@"
