#!/usr/bin/env bash
# migrate-mode.sh - Switch between global and per-project installation modes
# Usage: ./migrate-mode.sh [to-global|to-local]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Installation directories
GLOBAL_DIR="${AGENT_TOOLING_HOME:-$HOME/.agent-tooling}"
LOCAL_DIR=".agent-tools"

# Helper functions
error() { echo -e "${RED}❌ $1${NC}" >&2; }
success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

show_usage() {
    cat << EOF
Usage: $0 [to-global|to-local] [OPTIONS]

Migrate between installation modes:
  to-global    Convert per-project installation to global mode
  to-local     Convert global installation to per-project mode

Options:
  --dry-run    Show what would be done without making changes
  --backup     Create backup before migration (default: true)
  --no-backup  Skip backup creation
  --help       Show this help message

Examples:
  # Migrate current project to use global installation
  $0 to-global

  # Convert global setup to per-project (dry run)
  $0 to-local --dry-run

  # Migrate without creating backup
  $0 to-global --no-backup
EOF
}

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not a git repository. This script must be run from a git project."
        exit 1
    fi
}

# Detect current installation mode
detect_mode() {
    local has_local=false
    local has_global_init=false

    if [ -d "$LOCAL_DIR" ] || [ -f ".agent-tools.yaml" ]; then
        has_local=true
    fi

    if [ -f ".agent-tools.global-init" ] || [ -f ".agent-tools.local.yaml" ]; then
        has_global_init=true
    fi

    if [ "$has_local" = true ] && [ "$has_global_init" = false ]; then
        echo "local"
    elif [ "$has_global_init" = true ] && [ "$has_local" = false ]; then
        echo "global"
    elif [ "$has_local" = false ] && [ "$has_global_init" = false ]; then
        echo "none"
    else
        echo "mixed"
    fi
}

# Create backup of current state
create_backup() {
    local backup_dir=".agent-tools-migration-backup-$(date +%Y%m%d-%H%M%S)"

    info "Creating backup: $backup_dir"

    mkdir -p "$backup_dir"

    # Backup local files if they exist
    for item in "$LOCAL_DIR" ".agent-tools.yaml" ".agent-tools.local.yaml" \
                ".agent-tools.global-init" ".beads" ".claude" "AGENTS.md"; do
        if [ -e "$item" ]; then
            cp -r "$item" "$backup_dir/" 2>/dev/null || true
        fi
    done

    success "Backup created: $backup_dir"
    echo "$backup_dir" > .agent-tools-last-backup
}

# Migrate from per-project to global mode
migrate_to_global() {
    local dry_run=$1
    local create_backup=$2

    info "Migrating from per-project to global mode..."

    # Check if global installation exists
    if [ ! -d "$GLOBAL_DIR" ]; then
        error "Global installation not found at $GLOBAL_DIR"
        error "Please run install-global.sh first"
        exit 1
    fi

    # Create backup if requested
    if [ "$create_backup" = true ]; then
        if [ "$dry_run" = false ]; then
            create_backup
        else
            info "[DRY RUN] Would create backup"
        fi
    fi

    # Step 1: Migrate local config to .agent-tools.local.yaml
    if [ -f ".agent-tools.yaml" ]; then
        info "Migrating .agent-tools.yaml to .agent-tools.local.yaml"

        if [ "$dry_run" = false ]; then
            mv ".agent-tools.yaml" ".agent-tools.local.yaml"
            success "Config migrated to .agent-tools.local.yaml (overrides global config)"
        else
            info "[DRY RUN] Would rename .agent-tools.yaml -> .agent-tools.local.yaml"
        fi
    fi

    # Step 2: Remove local tool installations
    if [ -d "$LOCAL_DIR" ]; then
        info "Removing local tool installations (will use global)"

        if [ "$dry_run" = false ]; then
            rm -rf "$LOCAL_DIR"
            success "Removed $LOCAL_DIR"
        else
            info "[DRY RUN] Would remove $LOCAL_DIR"
        fi
    fi

    # Step 3: Preserve project-specific files (.beads, .claude, AGENTS.md)
    info "Keeping project-specific files (.beads, .claude, AGENTS.md)"
    # These stay in the project

    # Step 4: Register project with global installation
    local project_path=$(pwd)
    local project_name=$(basename "$project_path")
    local project_registry="$GLOBAL_DIR/projects/${project_name}.yaml"

    info "Registering project with global installation"

    if [ "$dry_run" = false ]; then
        mkdir -p "$GLOBAL_DIR/projects"

        cat > "$project_registry" << EOF
# Project: $project_name
path: "$project_path"
initialized: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
mode: global

# Project-specific settings
settings:
  local_config: $([ -f ".agent-tools.local.yaml" ] && echo "yes" || echo "no")
  has_beads: $([ -d ".beads" ] && echo "yes" || echo "no")
  has_claude: $([ -d ".claude" ] && echo "yes" || echo "no")
EOF

        # Create marker file
        touch ".agent-tools.global-init"

        success "Registered with global installation"
    else
        info "[DRY RUN] Would create $project_registry"
        info "[DRY RUN] Would create .agent-tools.global-init marker"
    fi

    # Step 5: Update .gitignore
    if [ "$dry_run" = false ]; then
        info "Updating .gitignore"

        # Remove old per-project entries
        if [ -f ".gitignore" ]; then
            sed -i.bak '/^\.agent-tools\/$/d' .gitignore
            sed -i.bak '/^\.agent-tools\.yaml$/d' .gitignore
            rm -f .gitignore.bak
        fi

        # Add new global mode entries
        if ! grep -q "^\.agent-tools\.local\.yaml$" .gitignore 2>/dev/null; then
            echo "" >> .gitignore
            echo "# Agent Tooling (Global Mode)" >> .gitignore
            echo ".agent-tools.local.yaml  # Per-project overrides" >> .gitignore
            echo ".agent-tools.global-init # Migration marker" >> .gitignore
        fi

        success "Updated .gitignore"
    else
        info "[DRY RUN] Would update .gitignore"
    fi

    echo ""
    success "Migration to global mode complete!"
    echo ""
    info "What changed:"
    echo "  • Removed local tool installations (now using $GLOBAL_DIR)"
    echo "  • Renamed .agent-tools.yaml → .agent-tools.local.yaml (project overrides)"
    echo "  • Registered project with global installation"
    echo "  • Updated .gitignore"
    echo ""
    info "What stayed:"
    echo "  • .beads/ (project issue database)"
    echo "  • .claude/ (project agent instructions)"
    echo "  • AGENTS.md (project workflow)"
    echo ""
    info "Next steps:"
    echo "  1. Test that tools work: agent-tools doctor"
    echo "  2. Review .agent-tools.local.yaml (edit project-specific settings)"
    echo "  3. Commit changes: git add .gitignore .agent-tools.local.yaml"
}

# Migrate from global to per-project mode
migrate_to_local() {
    local dry_run=$1
    local create_backup=$2

    info "Migrating from global to per-project mode..."

    # Create backup if requested
    if [ "$create_backup" = true ]; then
        if [ "$dry_run" = false ]; then
            create_backup
        else
            info "[DRY RUN] Would create backup"
        fi
    fi

    # Step 1: Merge configs
    if [ -f ".agent-tools.local.yaml" ]; then
        info "Converting .agent-tools.local.yaml to .agent-tools.yaml"

        if [ "$dry_run" = false ]; then
            mv ".agent-tools.local.yaml" ".agent-tools.yaml"
            success "Config converted to .agent-tools.yaml"
        else
            info "[DRY RUN] Would rename .agent-tools.local.yaml -> .agent-tools.yaml"
        fi
    elif [ -f "$GLOBAL_DIR/config/.agent-tools.yaml" ]; then
        info "Copying global config to project"

        if [ "$dry_run" = false ]; then
            cp "$GLOBAL_DIR/config/.agent-tools.yaml" ".agent-tools.yaml"
            success "Copied global config to .agent-tools.yaml"
        else
            info "[DRY RUN] Would copy global config"
        fi
    fi

    # Step 2: Install tools locally
    info "Installing tools to local directory"

    if [ "$dry_run" = false ]; then
        # Run the per-project installer
        if [ -f "install.sh" ]; then
            ./install.sh --skip-prompts
        else
            warn "install.sh not found. Download from:"
            echo "  curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh -o install.sh"
            echo "  chmod +x install.sh"
            echo "  ./install.sh"
        fi
    else
        info "[DRY RUN] Would run install.sh to install tools locally"
    fi

    # Step 3: Remove global mode markers
    if [ -f ".agent-tools.global-init" ]; then
        info "Removing global mode marker"

        if [ "$dry_run" = false ]; then
            rm ".agent-tools.global-init"
            success "Removed .agent-tools.global-init"
        else
            info "[DRY RUN] Would remove .agent-tools.global-init"
        fi
    fi

    # Step 4: Unregister from global installation
    local project_name=$(basename "$(pwd)")
    local project_registry="$GLOBAL_DIR/projects/${project_name}.yaml"

    if [ -f "$project_registry" ]; then
        info "Unregistering from global installation"

        if [ "$dry_run" = false ]; then
            rm "$project_registry"
            success "Unregistered from global installation"
        else
            info "[DRY RUN] Would remove $project_registry"
        fi
    fi

    # Step 5: Update .gitignore
    if [ "$dry_run" = false ]; then
        info "Updating .gitignore"

        if [ -f ".gitignore" ]; then
            # Remove global mode entries
            sed -i.bak '/^\.agent-tools\.local\.yaml/d' .gitignore
            sed -i.bak '/^\.agent-tools\.global-init/d' .gitignore
            rm -f .gitignore.bak
        fi

        # Add per-project entries
        if ! grep -q "^\.agent-tools/$" .gitignore 2>/dev/null; then
            echo "" >> .gitignore
            echo "# Agent Tooling (Per-Project Mode)" >> .gitignore
            echo ".agent-tools/  # Local tool installations" >> .gitignore
            echo ".agent-tools.yaml  # Project configuration" >> .gitignore
        fi

        success "Updated .gitignore"
    else
        info "[DRY RUN] Would update .gitignore"
    fi

    echo ""
    success "Migration to per-project mode complete!"
    echo ""
    info "What changed:"
    echo "  • Installed tools locally to $LOCAL_DIR"
    echo "  • Created .agent-tools.yaml (self-contained config)"
    echo "  • Unregistered from global installation"
    echo "  • Updated .gitignore"
    echo ""
    info "What stayed:"
    echo "  • .beads/ (project issue database)"
    echo "  • .claude/ (project agent instructions)"
    echo "  • AGENTS.md (project workflow)"
    echo ""
    info "Next steps:"
    echo "  1. Test that tools work: ./agent-tools-doctor.sh"
    echo "  2. Review .agent-tools.yaml"
    echo "  3. Commit changes: git add .gitignore .agent-tools.yaml"
}

# Main script
main() {
    local mode=""
    local dry_run=false
    local create_backup=true

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            to-global|to-local)
                mode="$1"
                shift
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --backup)
                create_backup=true
                shift
                ;;
            --no-backup)
                create_backup=false
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Validate arguments
    if [ -z "$mode" ]; then
        error "Missing required argument: [to-global|to-local]"
        show_usage
        exit 1
    fi

    # Check git repository
    check_git_repo

    # Detect current mode
    local current_mode=$(detect_mode)

    echo ""
    info "Current mode: $current_mode"
    info "Target mode: ${mode#to-}"
    if [ "$dry_run" = true ]; then
        warn "DRY RUN - No changes will be made"
    fi
    echo ""

    # Validate migration path
    if [ "$current_mode" = "none" ]; then
        error "No agent tooling installation detected"
        info "Please run install.sh or install-global.sh first"
        exit 1
    fi

    if [ "$current_mode" = "mixed" ]; then
        warn "Detected mixed installation (both global and local markers)"
        warn "This may indicate a previous incomplete migration"

        if [ "$create_backup" = false ]; then
            error "Cannot proceed without backup in mixed state"
            exit 1
        fi
    fi

    # Perform migration
    case "$mode" in
        to-global)
            if [ "$current_mode" = "global" ]; then
                success "Already using global mode!"
                exit 0
            fi
            migrate_to_global "$dry_run" "$create_backup"
            ;;
        to-local)
            if [ "$current_mode" = "local" ]; then
                success "Already using per-project mode!"
                exit 0
            fi
            migrate_to_local "$dry_run" "$create_backup"
            ;;
    esac
}

main "$@"
