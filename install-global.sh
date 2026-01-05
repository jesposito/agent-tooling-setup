#!/usr/bin/env bash
# Global Agent Tooling Installation Script
# Installs tools once to ~/.agent-tooling/ for use across all projects

set -e

VERSION="1.0.0"
GLOBAL_DIR="${AGENT_TOOLING_HOME:-$HOME/.agent-tooling}"
CONFIG_DIR="$GLOBAL_DIR/config"
PROJECTS_DIR="$GLOBAL_DIR/projects"
BIN_DIR="$GLOBAL_DIR/bin"
LIB_DIR="$GLOBAL_DIR/lib"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }
section() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

# Check prerequisites
check_prerequisites() {
    section "Checking Prerequisites"

    # Check Python
    if command -v python3 &> /dev/null; then
        local python_version=$(python3 --version 2>&1 | awk '{print $2}')
        success "Python: $python_version"
    elif command -v python &> /dev/null; then
        local python_version=$(python --version 2>&1 | awk '{print $2}')
        success "Python: $python_version"
    else
        error "Python 3.10+ required. Install from python.org"
    fi

    # Check if already installed
    if [ -d "$GLOBAL_DIR" ] && [ -f "$GLOBAL_DIR/.installed" ]; then
        warn "Agent tooling already installed globally at $GLOBAL_DIR"
        echo ""
        read -p "Reinstall? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Installation cancelled. To update, run: agent-tools update"
            exit 0
        fi
    fi
}

# Create directory structure
create_directory_structure() {
    section "Creating Directory Structure"

    mkdir -p "$GLOBAL_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$PROJECTS_DIR"
    mkdir -p "$BIN_DIR"
    mkdir -p "$LIB_DIR"
    mkdir -p "$LIB_DIR/python"
    mkdir -p "$LIB_DIR/node"

    success "Created $GLOBAL_DIR"
}

# Install tools globally
install_tools_globally() {
    section "Installing Tools"

    # Install Python tools with pipx (isolated) or to lib dir
    if command -v pipx &> /dev/null; then
        info "Installing Python tools with pipx (isolated environments)..."

        # Install gptme
        info "Installing gptme..."
        pipx install gptme --force 2>&1 | grep -v "^  " || true
        success "gptme installed"

        # Install aider
        info "Installing aider..."
        pipx install aider-chat --force 2>&1 | grep -v "^  " || true
        success "aider installed"

    else
        warn "pipx not found, installing to user directory instead"
        info "Tip: Install pipx for better isolation: pip install --user pipx"

        # Fallback to pip --user (show progress, these are big packages)
        info "Installing gptme (this may take 5-10 minutes)..."
        if pip3 install --user gptme 2>&1 || pip install --user gptme 2>&1; then
            success "gptme installed"
        else
            warn "gptme installation failed (optional)"
        fi

        info "Installing aider-chat (this may take 5-10 minutes)..."
        if pip3 install --user aider-chat 2>&1 || pip install --user aider-chat 2>&1; then
            success "aider installed"
        else
            warn "aider installation failed (optional)"
        fi
    fi

    # Install Empirica
    info "Installing Empirica..."
    if pip3 install --user git+https://github.com/Nubaeon/empirica.git 2>&1 || \
       pip install --user git+https://github.com/Nubaeon/empirica.git 2>&1; then
        success "Empirica installed"
    else
        warn "Empirica installation failed (optional)"
    fi

    # Install Mem0
    info "Installing Mem0 (this may take a few minutes)..."
    if pip3 install --user mem0ai 2>&1 || pip install --user mem0ai 2>&1; then
        success "Mem0 installed"
    else
        warn "Mem0 installation failed (optional)"
    fi

    # Install Beads
    info "Installing Beads..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if command -v brew &> /dev/null; then
            brew tap steveyegge/beads 2>/dev/null || true
            brew install steveyegge/beads/bd || curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
        else
            curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
        fi
    else
        # Linux or other
        curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
    fi

    # Check if bd is available
    if command -v bd &> /dev/null; then
        success "Beads installed"
    else
        # Try Go install
        if command -v go &> /dev/null; then
            warn "Trying Go installation..."
            go install github.com/steveyegge/beads/cmd/bd@latest
        fi
        # Try npm install
        if ! command -v bd &> /dev/null && command -v npm &> /dev/null; then
            warn "Trying npm installation..."
            npm install -g @beads/bd
        fi
    fi

    # Install Perles
    info "Installing Perles..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if command -v brew &> /dev/null; then
            brew tap zjrosen/perles 2>/dev/null || true
            brew install perles || curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash
        else
            curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash
        fi
    else
        curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash
    fi

    # Try Go install if not available
    if ! command -v perles &> /dev/null && command -v go &> /dev/null; then
        warn "Trying Go installation..."
        go install github.com/zjrosen/perles@latest
    fi

    if command -v perles &> /dev/null; then
        success "Perles installed"
    else
        warn "Perles installation failed (optional)"
    fi

    # Install OpenCommit (if Node.js available)
    if command -v npm &> /dev/null; then
        info "Installing OpenCommit..."
        npm install -g opencommit 2>&1 | grep -v "^  " || true
        success "OpenCommit installed"
    else
        warn "Node.js not found - skipping OpenCommit (optional)"
    fi
}

# Create global configuration
create_global_config() {
    section "Creating Global Configuration"

    # Copy configuration template
    local template_path="$(dirname "$0")/agent-tools.yaml.template"
    if [ -f "$template_path" ]; then
        cp "$template_path" "$CONFIG_DIR/.agent-tools.yaml"
        success "Created global configuration"
    else
        warn "Configuration template not found, creating minimal config"
        cat > "$CONFIG_DIR/.agent-tools.yaml" << 'EOF'
version: "1.0"
mode: "global"

core:
  beads:
    enabled: true
  empirica:
    enabled: true
  perles:
    enabled: true

ai_tools:
  opencommit:
    enabled: false
  gptme:
    enabled: false
  aider:
    enabled: false
  mem0:
    enabled: false
EOF
    fi

    # Create .env template
    cat > "$CONFIG_DIR/.env.template" << 'EOF'
# Agent Tooling - Global API Keys
# Copy this to .env and fill in your keys

# OpenAI (for OpenCommit, gptme, Aider, Mem0)
OPENAI_API_KEY=sk-...

# Anthropic (for gptme, Aider)
ANTHROPIC_API_KEY=sk-ant-...

# Google Gemini (for gptme, Mem0)
GEMINI_API_KEY=...

# Groq (for gptme)
GROQ_API_KEY=...

# Together AI (for Mem0)
TOGETHER_API_KEY=...
EOF

    success "Created .env template"
    info "Edit $CONFIG_DIR/.env.template and save as .env with your API keys"
}

# Create CLI wrapper
create_cli_wrapper() {
    section "Creating CLI Wrapper"

    cat > "$BIN_DIR/agent-tools" << 'EOF'
#!/usr/bin/env bash
# Agent Tools CLI Wrapper
# Provides unified interface for all agent tooling commands

GLOBAL_DIR="${AGENT_TOOLING_HOME:-$HOME/.agent-tooling}"
VERSION="1.0.0"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

cmd_init() {
    echo "Initializing project for agent tooling..."
    bash "$GLOBAL_DIR/scripts/agent-tools-init.sh" "$@"
}

cmd_doctor() {
    echo "Running diagnostics..."
    bash "$GLOBAL_DIR/scripts/agent-tools-doctor.sh" "$@"
}

cmd_update() {
    echo "Updating tools..."
    bash "$GLOBAL_DIR/scripts/agent-tools-update.sh" "$@"
}

cmd_config() {
    echo "Opening configuration..."
    ${EDITOR:-vi} "$GLOBAL_DIR/config/.agent-tools.yaml"
}

cmd_version() {
    echo "Agent Tooling v$VERSION (global mode)"
    echo "Installation: $GLOBAL_DIR"
}

cmd_help() {
    cat << HELP
Agent Tooling CLI v$VERSION

Usage:
    agent-tools <command> [options]

Commands:
    init          Initialize current project for agent tooling
    doctor        Run diagnostic health check
    update        Update all installed tools
    config        Edit global configuration
    version       Show version information
    help          Show this help message

Examples:
    agent-tools init                    # Set up current project
    agent-tools doctor                  # Check system health
    agent-tools update                  # Update all tools
    agent-tools config                  # Edit configuration

For more information, visit:
https://github.com/jesposito/agent-tooling-setup
HELP
}

# Main command dispatcher
case "${1:-help}" in
    init)       shift; cmd_init "$@" ;;
    doctor)     shift; cmd_doctor "$@" ;;
    update)     shift; cmd_update "$@" ;;
    config)     shift; cmd_config "$@" ;;
    version)    cmd_version ;;
    help|--help|-h) cmd_help ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'agent-tools help' for usage"
        exit 1
        ;;
esac
EOF

    chmod +x "$BIN_DIR/agent-tools"
    success "Created agent-tools CLI wrapper"
}

# Create initialization script
create_init_script() {
    section "Creating Initialization Script"

    mkdir -p "$GLOBAL_DIR/scripts"

    cat > "$GLOBAL_DIR/scripts/agent-tools-init.sh" << 'EOF'
#!/usr/bin/env bash
# Initialize a project for agent tooling (global mode)

set -e

GLOBAL_DIR="${AGENT_TOOLING_HOME:-$HOME/.agent-tooling}"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Get project root
PROJECT_ROOT=$(git rev-parse --show-toplevel)
PROJECT_NAME=$(basename "$PROJECT_ROOT")

info "Initializing $PROJECT_NAME for agent tooling (global mode)..."

# Create project state directory
PROJECT_HASH=$(echo -n "$PROJECT_ROOT" | shasum | cut -d' ' -f1)
PROJECT_STATE_DIR="$GLOBAL_DIR/projects/$PROJECT_NAME-$PROJECT_HASH"

mkdir -p "$PROJECT_STATE_DIR"
mkdir -p "$PROJECT_ROOT/.claude"

# Create symlink
ln -sf "$PROJECT_STATE_DIR" "$PROJECT_ROOT/.agent-tools.link" 2>/dev/null || {
    echo "$PROJECT_STATE_DIR" > "$PROJECT_ROOT/.agent-tools.link"
}

# Initialize beads if available
if command -v bd &> /dev/null; then
    cd "$PROJECT_STATE_DIR"
    if [ ! -d ".beads" ]; then
        bd init
        success "Beads initialized"
    fi
    cd "$PROJECT_ROOT"
else
    mkdir -p "$PROJECT_STATE_DIR/.beads"
    warn "Beads not available - created directory placeholder"
fi

# Create docs/DEVELOPMENT.md
if [ ! -f "$PROJECT_ROOT/docs/DEVELOPMENT.md" ]; then
    cat > "$PROJECT_ROOT/docs/DEVELOPMENT.md" << 'CLAUDE_EOF'
# Agent Tooling - Integrated Development Environment

This project uses agent tooling in **global mode**.

## 🧠 Empirica - Epistemic Self-Assessment
Track what you know and learn throughout development sessions.

```bash
empirica session-create --ai-id claude-code --output json
empirica preflight-submit -
empirica postflight-submit -
```

## 📋 Beads (bd) - Task & Issue Tracking
Distributed, git-backed graph issue tracker.

```bash
bd ready                    # List unblocked tasks
bd show <id>                # View issue details
bd update <id> --status in_progress
bd close <id>               # Complete work
bd sync                     # Sync with git
```

## 🎨 Perles - Visual Task Management
Terminal UI for Beads with kanban boards.

```bash
perles                      # Launch TUI
```

## 🔄 Integrated Workflow

1. **Session Start**
   - Run `empirica session-create`
   - Run `empirica preflight-submit -`
   - Run `bd ready` to identify available tasks

2. **During Development**
   - Use `bd` commands to track task progress
   - Use `perles` to visualize kanban board
   - Update issue status as work progresses

3. **Session End**
   - Run `empirica postflight-submit -`
   - Run `bd sync`
   - See AGENTS.md for mandatory landing-the-plane workflow

CLAUDE_EOF
    success "Created docs/DEVELOPMENT.md"
fi

# Create AGENTS.md
if [ ! -f "$PROJECT_ROOT/AGENTS.md" ]; then
    cat > "$PROJECT_ROOT/AGENTS.md" << 'AGENTS_EOF'
# Agent Workflow

## Landing the Plane

At the end of every development session, you **MUST** complete this checklist:

### 1. File Issues for Incomplete Work
- [ ] Create beads for any remaining TODOs or incomplete work
- [ ] Document blockers or dependencies
- [ ] Note any technical debt incurred

### 2. Run Quality Gates
- [ ] All tests pass
- [ ] Linters pass
- [ ] Build succeeds
- [ ] No new warnings

### 3. Update Beads Status
- [ ] Close completed beads: `bd close <id>`
- [ ] Update in-progress beads with current state
- [ ] Link related beads with dependencies

### 4. Sync Everything
```bash
bd sync                              # Sync beads with git
empirica postflight-submit -         # Document learnings
git add .                            # Stage changes
git commit -m "Descriptive message"  # Commit
git push                             # Push to remote (MANDATORY)
```

### 5. Verify
- [ ] All changes are pushed
- [ ] CI/CD builds are green
- [ ] No uncommitted changes remain

---

**CRITICAL**: Work is not complete until `git push` succeeds and CI passes.
AGENTS_EOF
    success "Created AGENTS.md"
fi

# Update .gitignore
if [ -f "$PROJECT_ROOT/.gitignore" ]; then
    if ! grep -q "# === Agent Tooling" "$PROJECT_ROOT/.gitignore"; then
        cat >> "$PROJECT_ROOT/.gitignore" << 'GITIGNORE_EOF'

# === Agent Tooling - Auto-managed (DO NOT EDIT) ===
# Global mode - state stored in ~/.agent-tooling/projects/
.agent-tools.link

# API keys and secrets (CRITICAL - never commit!)
.env
.env.local
.env.*.local

# Tool-specific temp/cache
.mem0-cache/
.gptme-cache/
.gptme-sessions/
.aider-cache/
.coderabbit-cache/
.empirica-sessions/
# === End Agent Tooling ===
GITIGNORE_EOF
        success "Updated .gitignore"
    fi
fi

# Create metadata
cat > "$PROJECT_STATE_DIR/metadata.json" << METADATA_EOF
{
  "project_name": "$PROJECT_NAME",
  "project_root": "$PROJECT_ROOT",
  "initialized_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "mode": "global"
}
METADATA_EOF

success "Project initialized!"
info "State directory: $PROJECT_STATE_DIR"
info "Run 'bd ready' to see available tasks"
info "Run 'agent-tools doctor' to verify installation"
EOF

    chmod +x "$GLOBAL_DIR/scripts/agent-tools-init.sh"
    success "Created initialization script"
}

# Copy diagnostic and update scripts
copy_utility_scripts() {
    section "Installing Utility Scripts"

    local source_dir="$(dirname "$0")"

    # Copy diagnostic script
    if [ -f "$source_dir/agent-tools-doctor.sh" ]; then
        cp "$source_dir/agent-tools-doctor.sh" "$GLOBAL_DIR/scripts/"
        chmod +x "$GLOBAL_DIR/scripts/agent-tools-doctor.sh"
        success "Installed diagnostic script"
    fi

    # Copy update script
    if [ -f "$source_dir/agent-tools-update.sh" ]; then
        cp "$source_dir/agent-tools-update.sh" "$GLOBAL_DIR/scripts/"
        chmod +x "$GLOBAL_DIR/scripts/agent-tools-update.sh"
        success "Installed update script"
    fi
}

# Setup PATH
setup_path() {
    section "Setting Up PATH"

    local shell_config=""
    local shell_name=$(basename "$SHELL")

    case "$shell_name" in
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                shell_config="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                shell_config="$HOME/.bash_profile"
            fi
            ;;
        zsh)
            shell_config="$HOME/.zshrc"
            ;;
        fish)
            shell_config="$HOME/.config/fish/config.fish"
            ;;
        *)
            warn "Unknown shell: $shell_name"
            info "Add this to your shell config manually:"
            echo "  export PATH=\"$BIN_DIR:\$PATH\""
            return
            ;;
    esac

    if [ -n "$shell_config" ]; then
        if ! grep -q "agent-tooling" "$shell_config" 2>/dev/null; then
            echo "" >> "$shell_config"
            echo "# Agent Tooling (added by install-global.sh)" >> "$shell_config"
            echo "export AGENT_TOOLING_HOME=\"$GLOBAL_DIR\"" >> "$shell_config"
            echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$shell_config"

            success "Added to $shell_config"
            warn "Run: source $shell_config"
            warn "Or restart your terminal"
        else
            info "Already in PATH"
        fi
    fi
}

# Create installation marker
finalize_installation() {
    cat > "$GLOBAL_DIR/.installed" << EOF
Agent Tooling Global Installation
Installed: $(date)
Version: $VERSION
Location: $GLOBAL_DIR
EOF

    success "Installation complete!"
}

# Main installation flow
main() {
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   Agent Tooling Global Installation v${VERSION}       ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""

    info "Installing to: $GLOBAL_DIR"
    echo ""

    check_prerequisites
    create_directory_structure
    install_tools_globally
    create_global_config
    create_cli_wrapper
    create_init_script
    copy_utility_scripts
    setup_path
    finalize_installation

    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   ✓ Global Installation Complete!                     ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""
    success "Agent tooling is installed globally"
    echo ""
    info "Next steps:"
    echo "  1. Restart your terminal (or source your shell config)"
    echo "  2. cd to a project directory"
    echo "  3. Run: agent-tools init"
    echo "  4. Run: agent-tools doctor"
    echo ""
    info "Commands available:"
    echo "  agent-tools init       - Initialize current project"
    echo "  agent-tools doctor     - Run diagnostics"
    echo "  agent-tools update     - Update all tools"
    echo "  agent-tools config     - Edit configuration"
    echo ""
    info "Global installation: $GLOBAL_DIR"
    echo ""
}

main "$@"
