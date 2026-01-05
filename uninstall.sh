#!/usr/bin/env bash
set -e

# Agent Tooling Setup Uninstaller
# Removes configuration files (keeps tools installed)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   Agent Tooling Setup - Uninstaller                   ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "Not a git repository."
    exit 1
fi

# Parse arguments
REMOVE_TOOLS=false
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --remove-tools)
            REMOVE_TOOLS=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --help)
            echo "Usage: uninstall.sh [options]"
            echo ""
            echo "Options:"
            echo "  --remove-tools  Also uninstall bd, perles, and empirica"
            echo "  --dry-run       Show what would be removed without removing"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Files and directories to remove
FILES=(
    ".beads"
    ".claude/CLAUDE.md"
    "AGENTS.md"
    ".gitattributes"
)

# Optional files
OPTIONAL_FILES=(
    "agent-instructions.md"
    ".perles"
)

info "Checking for agent tooling files..."
echo ""

# Check what exists
FILES_TO_REMOVE=()
for file in "${FILES[@]}"; do
    if [ -e "$file" ]; then
        echo "  • $file"
        FILES_TO_REMOVE+=("$file")
    fi
done

# Check optional files
OPTIONAL_TO_REMOVE=()
for file in "${OPTIONAL_FILES[@]}"; do
    if [ -e "$file" ]; then
        OPTIONAL_TO_REMOVE+=("$file")
    fi
done

if [ ${#OPTIONAL_TO_REMOVE[@]} -gt 0 ]; then
    echo ""
    warn "Optional files found (created by user, not auto-removed):"
    for file in "${OPTIONAL_TO_REMOVE[@]}"; do
        echo "  • $file"
    done
fi

if [ ${#FILES_TO_REMOVE[@]} -eq 0 ]; then
    info "No agent tooling files found in this project"
    exit 0
fi

# Confirm removal
if [ "$DRY_RUN" != "true" ]; then
    echo ""
    read -p "Remove these files? [y/N] " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Cancelled"
        exit 0
    fi

    # Remove files
    info "Removing files..."
    for file in "${FILES_TO_REMOVE[@]}"; do
        if git ls-files --error-unmatch "$file" > /dev/null 2>&1; then
            # File is tracked by git
            git rm -rf "$file" > /dev/null 2>&1 || rm -rf "$file"
            success "Removed $file (from git)"
        else
            # File is not tracked
            rm -rf "$file"
            success "Removed $file"
        fi
    done

    # Clean up empty .claude directory
    if [ -d ".claude" ] && [ -z "$(ls -A .claude)" ]; then
        rmdir .claude
        success "Removed empty .claude directory"
    fi
else
    warn "DRY RUN - No files removed"
fi

# Remove tools if requested
if [ "$REMOVE_TOOLS" = "true" ]; then
    echo ""
    info "Removing tools..."

    if command -v brew &> /dev/null; then
        brew uninstall bd 2>/dev/null && success "Removed bd" || warn "bd not installed via brew"
        brew uninstall perles 2>/dev/null && success "Removed perles" || warn "perles not installed via brew"
    fi

    if command -v pip3 &> /dev/null; then
        pip3 uninstall -y empirica-app 2>/dev/null && success "Removed empirica" || warn "empirica not installed via pip3"
    fi
fi

echo ""
success "Uninstall complete!"
echo ""

if [ "$REMOVE_TOOLS" != "true" ]; then
    info "Tools (bd, perles, empirica) are still installed"
    info "To remove them, run: ./uninstall.sh --remove-tools"
fi

if [ ${#OPTIONAL_TO_REMOVE[@]} -gt 0 ]; then
    echo ""
    info "Optional files were not removed:"
    for file in "${OPTIONAL_TO_REMOVE[@]}"; do
        echo "  • $file"
    done
    info "Remove them manually if needed"
fi

echo ""
