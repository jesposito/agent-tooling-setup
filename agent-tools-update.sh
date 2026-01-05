#!/usr/bin/env bash
# Agent Tooling Update System
# Safely updates all installed tools with pre/post health checks

set -e

VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }
section() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

# Track update results
UPDATES_SUCCESSFUL=0
UPDATES_FAILED=0
UPDATES_SKIPPED=0

# ============================================================================
# PRE-UPDATE HEALTH CHECK
# ============================================================================

pre_update_check() {
    section "Pre-Update Health Check"

    info "Running diagnostics before update..."

    if [ -f "./agent-tools-doctor.sh" ]; then
        chmod +x ./agent-tools-doctor.sh
        if ./agent-tools-doctor.sh; then
            success "System is healthy, proceeding with updates"
            return 0
        else
            warn "Some health check issues detected"
            echo ""
            read -p "Continue with update anyway? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                error "Update cancelled by user"
                exit 1
            fi
        fi
    else
        warn "Diagnostic tool not found, skipping pre-check"
    fi
}

# ============================================================================
# BACKUP CURRENT STATE
# ============================================================================

create_backup() {
    section "Creating Backup"

    local backup_dir=".agent-tools-backup-$(date +%Y%m%d-%H%M%S)"

    info "Backing up current configuration to $backup_dir"

    mkdir -p "$backup_dir"

    # Backup critical files
    [ -f ".agent-tools.yaml" ] && cp ".agent-tools.yaml" "$backup_dir/"
    [ -f ".env" ] && cp ".env" "$backup_dir/"
    [ -d ".beads" ] && cp -r ".beads" "$backup_dir/"
    [ -d ".claude" ] && cp -r ".claude" "$backup_dir/"

    success "Backup created: $backup_dir"
    echo "$backup_dir"
}

# ============================================================================
# UPDATE FUNCTIONS
# ============================================================================

update_beads() {
    section "Updating Beads"

    if ! command -v bd &> /dev/null; then
        info "Beads not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    local current_version=$(bd version 2>&1 || echo "unknown")
    info "Current version: $current_version"

    # Update based on installation method
    if command -v brew &> /dev/null && brew list bd &> /dev/null; then
        info "Updating via Homebrew..."
        if brew upgrade bd 2>&1; then
            success "Beads updated via Homebrew"
            UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
        else
            warn "Homebrew update failed, trying install script..."
            update_beads_install_script
        fi
    else
        update_beads_install_script
    fi

    local new_version=$(bd version 2>&1 || echo "unknown")
    info "New version: $new_version"
}

update_beads_install_script() {
    info "Updating via install script..."
    if curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash; then
        success "Beads updated successfully"
        UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
    else
        error "Failed to update Beads"
        UPDATES_FAILED=$((UPDATES_FAILED + 1))
    fi
}

update_perles() {
    section "Updating Perles"

    if ! command -v perles &> /dev/null; then
        info "Perles not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    # Update based on installation method
    if command -v brew &> /dev/null && brew list perles &> /dev/null; then
        info "Updating via Homebrew..."
        if brew upgrade perles 2>&1; then
            success "Perles updated via Homebrew"
            UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
        else
            warn "Homebrew update failed, trying install script..."
            update_perles_install_script
        fi
    else
        update_perles_install_script
    fi
}

update_perles_install_script() {
    info "Updating via install script..."
    if curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash; then
        success "Perles updated successfully"
        UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
    else
        error "Failed to update Perles"
        UPDATES_FAILED=$((UPDATES_FAILED + 1))
    fi
}

update_empirica() {
    section "Updating Empirica"

    if ! command -v empirica &> /dev/null; then
        info "Empirica not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    local current_version=$(empirica --version 2>&1 | head -1 || echo "unknown")
    info "Current version: $current_version"

    info "Updating via pip..."
    if pip3 install --user --upgrade --force-reinstall git+https://github.com/Nubaeon/empirica.git; then
        success "Empirica updated successfully"
        UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
    else
        error "Failed to update Empirica"
        UPDATES_FAILED=$((UPDATES_FAILED + 1))
    fi

    local new_version=$(empirica --version 2>&1 | head -1 || echo "unknown")
    info "New version: $new_version"
}

update_opencommit() {
    section "Updating OpenCommit"

    if ! command -v oco &> /dev/null; then
        info "OpenCommit not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    local current_version=$(oco --version 2>&1 || echo "unknown")
    info "Current version: $current_version"

    info "Updating via npm..."
    if npm update -g opencommit; then
        success "OpenCommit updated successfully"
        UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
    else
        error "Failed to update OpenCommit"
        UPDATES_FAILED=$((UPDATES_FAILED + 1))
    fi

    local new_version=$(oco --version 2>&1 || echo "unknown")
    info "New version: $new_version"
}

update_gptme() {
    section "Updating gptme"

    if ! command -v gptme &> /dev/null; then
        info "gptme not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    info "Updating via pipx..."
    if pipx upgrade gptme 2>&1; then
        success "gptme updated successfully"
        UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
    elif pip3 show gptme &> /dev/null; then
        info "Updating via pip..."
        if pip3 install --user --upgrade gptme; then
            success "gptme updated successfully"
            UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
        else
            error "Failed to update gptme"
            UPDATES_FAILED=$((UPDATES_FAILED + 1))
        fi
    else
        error "Failed to update gptme"
        UPDATES_FAILED=$((UPDATES_FAILED + 1))
    fi
}

update_aider() {
    section "Updating Aider"

    if ! command -v aider &> /dev/null; then
        info "Aider not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    info "Updating via pipx..."
    if pipx upgrade aider-chat 2>&1; then
        success "Aider updated successfully"
        UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
    elif pip3 show aider-chat &> /dev/null; then
        info "Updating via pip..."
        if pip3 install --user --upgrade aider-chat; then
            success "Aider updated successfully"
            UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
        else
            error "Failed to update Aider"
            UPDATES_FAILED=$((UPDATES_FAILED + 1))
        fi
    else
        error "Failed to update Aider"
        UPDATES_FAILED=$((UPDATES_FAILED + 1))
    fi
}

update_mem0() {
    section "Updating Mem0"

    if ! python3 -c "import mem0" 2>/dev/null; then
        info "Mem0 not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    info "Updating via pip..."
    if pip3 install --user --upgrade mem0ai; then
        success "Mem0 updated successfully"
        UPDATES_SUCCESSFUL=$((UPDATES_SUCCESSFUL + 1))
    else
        error "Failed to update Mem0"
        UPDATES_FAILED=$((UPDATES_FAILED + 1))
    fi
}

update_coderabbit() {
    section "Updating CodeRabbit CLI"

    if ! command -v coderabbit &> /dev/null; then
        info "CodeRabbit CLI not installed, skipping"
        UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
        return 0
    fi

    warn "CodeRabbit CLI updates must be done manually"
    info "Visit: https://www.coderabbit.ai/cli for update instructions"
    UPDATES_SKIPPED=$((UPDATES_SKIPPED + 1))
}

# ============================================================================
# POST-UPDATE HEALTH CHECK
# ============================================================================

post_update_check() {
    section "Post-Update Health Check"

    info "Running diagnostics after update..."

    if [ -f "./agent-tools-doctor.sh" ]; then
        chmod +x ./agent-tools-doctor.sh
        if ./agent-tools-doctor.sh; then
            success "Post-update health check passed"
            return 0
        else
            warn "Some issues detected after update"
            return 1
        fi
    else
        warn "Diagnostic tool not found, skipping post-check"
        return 0
    fi
}

# ============================================================================
# ROLLBACK
# ============================================================================

offer_rollback() {
    local backup_dir="$1"

    echo ""
    error "Update process encountered errors"
    echo ""
    read -p "Restore from backup? (y/N) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        info "Restoring from backup: $backup_dir"

        [ -f "$backup_dir/.agent-tools.yaml" ] && cp "$backup_dir/.agent-tools.yaml" "./"
        [ -f "$backup_dir/.env" ] && cp "$backup_dir/.env" "./"
        [ -d "$backup_dir/.beads" ] && cp -r "$backup_dir/.beads" "./"
        [ -d "$backup_dir/.claude" ] && cp -r "$backup_dir/.claude" "./"

        success "Configuration restored from backup"
        warn "Tool binaries not rolled back - may need manual reinstall"
    fi
}

# ============================================================================
# SUMMARY
# ============================================================================

show_summary() {
    section "Update Summary"

    echo "╔════════════════════════════════════╗"
    echo "║   Update Results                   ║"
    echo "╠════════════════════════════════════╣"
    echo "║  ✓ Successful: $UPDATES_SUCCESSFUL                  ║"
    echo "║  ✗ Failed:     $UPDATES_FAILED                  ║"
    echo "║  ⊘ Skipped:    $UPDATES_SKIPPED                  ║"
    echo "╚════════════════════════════════════╝"

    if [ $UPDATES_FAILED -gt 0 ]; then
        echo ""
        warn "Some updates failed. Review the errors above."
        info "You can try running individual update commands manually."
    elif [ $UPDATES_SUCCESSFUL -gt 0 ]; then
        echo ""
        success "All updates completed successfully!"
    else
        echo ""
        info "No updates were performed (all tools skipped or up-to-date)"
    fi
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   Agent Tooling Update System v${VERSION}            ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""

    # Parse arguments
    FORCE_UPDATE=false
    SKIP_HEALTH_CHECK=false
    UPDATE_ALL=true
    TOOLS_TO_UPDATE=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE_UPDATE=true
                shift
                ;;
            --skip-health-check)
                SKIP_HEALTH_CHECK=true
                shift
                ;;
            --tool)
                UPDATE_ALL=false
                TOOLS_TO_UPDATE+=("$2")
                shift 2
                ;;
            --help)
                echo "Usage: agent-tools-update.sh [options]"
                echo ""
                echo "Options:"
                echo "  --force                  Force update even if health check fails"
                echo "  --skip-health-check      Skip pre/post health checks"
                echo "  --tool <name>            Update specific tool only"
                echo "                           (beads, perles, empirica, opencommit, gptme, aider, mem0)"
                echo "  --help                   Show this help message"
                echo ""
                echo "Examples:"
                echo "  ./agent-tools-update.sh                    # Update all installed tools"
                echo "  ./agent-tools-update.sh --tool beads       # Update only Beads"
                echo "  ./agent-tools-update.sh --force            # Force update despite issues"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Pre-update health check
    if [ "$SKIP_HEALTH_CHECK" != "true" ]; then
        pre_update_check
    fi

    # Create backup
    local backup_dir=$(create_backup)

    # Update tools
    if [ "$UPDATE_ALL" = "true" ]; then
        info "Updating all installed tools..."
        update_beads
        update_perles
        update_empirica
        update_opencommit
        update_gptme
        update_aider
        update_mem0
        update_coderabbit
    else
        info "Updating selected tools: ${TOOLS_TO_UPDATE[*]}"
        for tool in "${TOOLS_TO_UPDATE[@]}"; do
            case "$tool" in
                beads) update_beads ;;
                perles) update_perles ;;
                empirica) update_empirica ;;
                opencommit) update_opencommit ;;
                gptme) update_gptme ;;
                aider) update_aider ;;
                mem0) update_mem0 ;;
                coderabbit) update_coderabbit ;;
                *) error "Unknown tool: $tool" ;;
            esac
        done
    fi

    # Post-update health check
    if [ "$SKIP_HEALTH_CHECK" != "true" ]; then
        if ! post_update_check; then
            if [ $UPDATES_FAILED -gt 0 ]; then
                offer_rollback "$backup_dir"
            fi
        fi
    fi

    # Show summary
    echo ""
    show_summary

    # Cleanup old backups (keep last 5)
    info "Cleaning up old backups (keeping last 5)..."
    ls -dt .agent-tools-backup-* 2>/dev/null | tail -n +6 | xargs rm -rf 2>/dev/null || true

    # Exit with appropriate code
    if [ $UPDATES_FAILED -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

main "$@"
