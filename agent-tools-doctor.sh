#!/usr/bin/env bash
# Agent Tooling Diagnostic & Health Check System
# Automatically validates installation, checks for issues, and suggests fixes

set -e

VERSION="1.0.0"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Diagnostic results
CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNING=0
ISSUES_FOUND=()
FIXES_SUGGESTED=()

# Output functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; CHECKS_PASSED=$((CHECKS_PASSED + 1)); }
warn() { echo -e "${YELLOW}⚠${NC} $1"; CHECKS_WARNING=$((CHECKS_WARNING + 1)); }
error() { echo -e "${RED}✗${NC} $1"; CHECKS_FAILED=$((CHECKS_FAILED + 1)); }
section() { echo -e "\n${CYAN}━━━ $1 ━━━${NC}"; }

# Add issue with suggested fix
add_issue() {
    local issue="$1"
    local fix="$2"
    ISSUES_FOUND+=("$issue")
    FIXES_SUGGESTED+=("$fix")
}

# ============================================================================
# DIAGNOSTIC CHECKS
# ============================================================================

# Check if tool is installed
check_tool() {
    local tool_name="$1"
    local command_name="$2"
    local install_help="$3"

    if command -v "$command_name" &> /dev/null; then
        local version=$($command_name --version 2>&1 | head -1 || echo "unknown")
        success "$tool_name installed: $version"
        return 0
    else
        error "$tool_name not found"
        add_issue "$tool_name is not installed" "$install_help"
        return 1
    fi
}

# Check Python version
check_python_version() {
    section "Python Environment"

    # Try python3 first, then python (Windows)
    local python_cmd=""
    if command -v python3 &> /dev/null; then
        python_cmd="python3"
    elif command -v python &> /dev/null; then
        python_cmd="python"
    else
        error "Python not found"
        add_issue "Python 3 is required" "Install Python 3.10-3.12 from python.org"
        return 1
    fi

    local python_version=$($python_cmd --version 2>&1 | awk '{print $2}')

    # Validate version is numeric
    if [[ ! "$python_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        error "Could not determine Python version"
        add_issue "Python version detection failed" "Check Python installation"
        return 1
    fi

    local major=$(echo "$python_version" | cut -d. -f1)
    local minor=$(echo "$python_version" | cut -d. -f2)

    if [ "$major" -eq 3 ] && [ "$minor" -ge 10 ] && [ "$minor" -le 12 ]; then
        success "Python version: $python_version (compatible)"
    elif [ "$major" -eq 3 ] && [ "$minor" -ge 9 ]; then
        warn "Python version: $python_version (works, but 3.10-3.12 recommended)"
    else
        error "Python version: $python_version (incompatible)"
        add_issue "Python 3.10-3.12 required for best compatibility" "Upgrade Python to 3.10, 3.11, or 3.12"
    fi
}

# Check Node.js (for OpenCommit)
check_nodejs() {
    if command -v node &> /dev/null; then
        local node_version=$(node --version 2>&1)
        success "Node.js installed: $node_version"
    else
        info "Node.js not found (optional - only needed for OpenCommit)"
    fi
}

# Check core tools
check_core_tools() {
    section "Core Tools"

    check_tool "Beads" "bd" "Run: curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash"
    check_tool "Empirica" "empirica" "Run: pip install --user git+https://github.com/Nubaeon/empirica.git"
    check_tool "Perles" "perles" "Run: curl -sSL https://raw.githubusercontent.com/zjrosen/perles/main/install.sh | bash"
}

# Check optional tools
check_optional_tools() {
    section "Optional AI Tools"

    # Check each tool and report status
    if command -v oco &> /dev/null; then
        success "OpenCommit installed"
    else
        info "OpenCommit not installed (optional)"
    fi

    if command -v gptme &> /dev/null; then
        success "gptme installed"
    else
        info "gptme not installed (optional)"
    fi

    if command -v aider &> /dev/null; then
        success "Aider installed"
    else
        info "Aider not installed (optional)"
    fi

    if command -v coderabbit &> /dev/null; then
        success "CodeRabbit CLI installed"
    else
        info "CodeRabbit CLI not installed (optional)"
    fi

    # Python packages
    if python3 -c "import mem0" 2>/dev/null; then
        success "Mem0 installed"
    else
        info "Mem0 not installed (optional)"
    fi
}

# Check git repository
check_git_repo() {
    section "Git Repository"

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Not in a git repository"
        add_issue "Must run in a git repository" "Run: git init"
        return 1
    fi

    success "Valid git repository"

    # Check for .gitignore
    if [ -f ".gitignore" ]; then
        if grep -q "# === Agent Tooling" ".gitignore" 2>/dev/null; then
            success ".gitignore has agent tooling entries"
        else
            warn ".gitignore missing agent tooling entries"
            add_issue ".gitignore not configured" "Re-run install.sh to update .gitignore"
        fi
    else
        warn ".gitignore not found"
        add_issue "No .gitignore file" "Re-run install.sh to create .gitignore"
    fi
}

# Check project structure
check_project_structure() {
    section "Project Structure"

    [ -d ".beads" ] && success ".beads/ directory exists" || { error ".beads/ missing"; add_issue "Beads not initialized" "Run: bd init"; }
    [ -d ".claude" ] && success ".claude/ directory exists" || warn ".claude/ missing (run install.sh)"
    [ -f ".claude/CLAUDE.md" ] && success ".claude/CLAUDE.md exists" || warn ".claude/CLAUDE.md missing"
    [ -f "AGENTS.md" ] && success "AGENTS.md exists" || warn "AGENTS.md missing"
    [ -f ".gitattributes" ] && success ".gitattributes exists" || warn ".gitattributes missing"
}

# Check API keys
check_api_keys() {
    section "API Keys"

    local keys_found=0

    # Check environment variables
    [ -n "$OPENAI_API_KEY" ] && { success "OPENAI_API_KEY set"; keys_found=1; }
    [ -n "$ANTHROPIC_API_KEY" ] && { success "ANTHROPIC_API_KEY set"; keys_found=1; }
    [ -n "$GEMINI_API_KEY" ] && { success "GEMINI_API_KEY set"; keys_found=1; }

    # Check .env file
    if [ -f ".env" ]; then
        success ".env file exists"
        if grep -q "API_KEY" ".env" 2>/dev/null; then
            info "API keys configured in .env"
            keys_found=1
        fi
    fi

    if [ $keys_found -eq 0 ]; then
        warn "No API keys found"
        add_issue "AI tools require API keys" "Create .env file with your API keys (see .env.template)"
    fi
}

# Check for dependency conflicts
check_dependencies() {
    section "Dependency Health"

    # Check for common Python dependency conflicts
    if command -v pip3 &> /dev/null; then
        info "Checking for package conflicts..."

        # Check for known conflicting versions
        if python3 -c "import litellm" 2>/dev/null; then
            local litellm_version=$(python3 -c "import litellm; print(litellm.__version__)" 2>/dev/null || echo "unknown")
            info "litellm version: $litellm_version"
        fi

        if python3 -c "import pydantic" 2>/dev/null; then
            local pydantic_version=$(python3 -c "import pydantic; print(pydantic.__version__)" 2>/dev/null || echo "unknown")
            local major=$(echo "$pydantic_version" | cut -d. -f1)
            if [ "$major" -ge 2 ]; then
                success "pydantic version: $pydantic_version (v2+)"
            else
                warn "pydantic version: $pydantic_version (v2+ recommended)"
            fi
        fi
    fi
}

# Check disk space
check_disk_space() {
    section "Resource Usage"

    # Check available disk space
    local available_space=$(df -BG . | awk 'NR==2 {print $4}' | sed 's/G//')

    if [ "$available_space" -gt 5 ]; then
        success "Disk space: ${available_space}GB available"
    elif [ "$available_space" -gt 2 ]; then
        warn "Disk space: ${available_space}GB available (low)"
    else
        error "Disk space: ${available_space}GB available (critically low)"
        add_issue "Low disk space" "Free up at least 2GB for tool installation"
    fi

    # Check size of .beads directory if it exists
    if [ -d ".beads" ]; then
        local beads_size=$(du -sh .beads 2>/dev/null | cut -f1 || echo "unknown")
        info ".beads/ size: $beads_size"
    fi
}

# Test tool functionality
test_tool_functionality() {
    section "Tool Functionality Tests"

    # Test Beads
    if command -v bd &> /dev/null; then
        if bd version &> /dev/null; then
            success "Beads functional"
        else
            error "Beads installed but not working"
            add_issue "Beads not functioning" "Reinstall Beads"
        fi
    fi

    # Test Empirica
    if command -v empirica &> /dev/null; then
        if empirica --help &> /dev/null; then
            success "Empirica functional"
        else
            error "Empirica installed but not working"
            add_issue "Empirica not functioning" "Run: pip install --user --force-reinstall git+https://github.com/Nubaeon/empirica.git"
        fi
    fi

    # Test Perles
    if command -v perles &> /dev/null; then
        if perles --version &> /dev/null; then
            success "Perles functional"
        else
            warn "Perles installed but version check failed (may be normal)"
        fi
    fi
}

# Check for known issues in external repos
check_external_repo_status() {
    section "External Repository Status"

    info "Checking if external repositories are accessible..."

    # Check GitHub API availability (without requiring auth)
    if curl -s --head --max-time 5 https://github.com > /dev/null 2>&1; then
        success "GitHub accessible"

        # Check specific repositories
        for repo in "steveyegge/beads" "zjrosen/perles" "Nubaeon/empirica"; do
            if curl -s --head --max-time 5 "https://github.com/$repo" > /dev/null 2>&1; then
                success "Repository $repo accessible"
            else
                warn "Repository $repo may be inaccessible"
            fi
        done
    else
        warn "GitHub not accessible (network issue or rate limiting)"
        add_issue "Cannot reach GitHub" "Check internet connection or wait for rate limits to reset"
    fi
}

# Version compatibility check
check_version_compatibility() {
    section "Version Compatibility"

    local compat_issues=0

    # Check if gptme and aider are both installed (potential Python version conflict)
    if command -v gptme &> /dev/null && command -v aider &> /dev/null; then
        local python_minor=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f2)
        if [ "$python_minor" -ge 13 ]; then
            error "Python 3.$python_minor may be incompatible with Aider (<3.13 required)"
            add_issue "Python version too new for Aider" "Use Python 3.10-3.12 or uninstall Aider"
            compat_issues=1
        fi
    fi

    if [ $compat_issues -eq 0 ]; then
        success "No version conflicts detected"
    fi
}

# ============================================================================
# AI-POWERED DIAGNOSTICS (EXPERIMENTAL)
# ============================================================================

run_ai_diagnostics() {
    section "AI-Powered Analysis (Experimental)"

    # Check if we have API keys and gptme installed
    if ! command -v gptme &> /dev/null; then
        info "gptme not installed - skipping AI diagnostics"
        info "Install gptme for AI-powered issue analysis: pipx install gptme"
        return 0
    fi

    if [ -z "$OPENAI_API_KEY" ] && [ -z "$ANTHROPIC_API_KEY" ]; then
        info "No API keys found - skipping AI diagnostics"
        return 0
    fi

    info "Running AI-powered diagnostic analysis..."

    # Create diagnostic context for AI
    local diagnostic_context=$(cat <<EOF
Agent Tooling Diagnostic Context:

Checks Passed: $CHECKS_PASSED
Checks Failed: $CHECKS_FAILED
Warnings: $CHECKS_WARNING

Issues Found:
$(printf '%s\n' "${ISSUES_FOUND[@]}")

Current Environment:
- Python: $(python3 --version 2>&1)
- Node.js: $(node --version 2>&1 || echo "Not installed")
- Git: $(git --version 2>&1)
- OS: $(uname -s)

Please analyze these diagnostic results and suggest:
1. Root causes of any failures
2. Priority order for fixes
3. Potential hidden issues not detected by automated checks
4. Best practices for this setup

Be concise and actionable.
EOF
)

    # Run AI analysis (if available)
    echo "$diagnostic_context" | gptme --no-confirm "Analyze this diagnostic report and provide recommendations" 2>/dev/null || {
        info "AI analysis not available (requires configured gptme)"
    }
}

# ============================================================================
# AUTOMATIC FIX SUGGESTIONS
# ============================================================================

suggest_fixes() {
    if [ ${#ISSUES_FOUND[@]} -eq 0 ]; then
        return 0
    fi

    section "Suggested Fixes"

    echo "Found ${#ISSUES_FOUND[@]} issue(s) that need attention:"
    echo ""

    for i in "${!ISSUES_FOUND[@]}"; do
        echo -e "${YELLOW}Issue $((i+1)):${NC} ${ISSUES_FOUND[$i]}"
        echo -e "${GREEN}Fix:${NC} ${FIXES_SUGGESTED[$i]}"
        echo ""
    done

    # Offer to auto-fix if possible
    if [ "$AUTO_FIX" = "true" ]; then
        info "Auto-fix mode enabled - attempting repairs..."
        attempt_auto_fixes
    else
        echo -e "${BLUE}Tip:${NC} Run with --auto-fix to attempt automatic repairs"
    fi
}

# Attempt automatic fixes
attempt_auto_fixes() {
    info "Auto-fix feature coming soon..."
    # TODO: Implement automatic fixes for common issues
}

# ============================================================================
# HEALTH SCORE
# ============================================================================

calculate_health_score() {
    local total_checks=$((CHECKS_PASSED + CHECKS_FAILED + CHECKS_WARNING))
    if [ $total_checks -eq 0 ]; then
        echo 0
        return
    fi

    local score=$(( (CHECKS_PASSED * 100) / total_checks ))
    echo $score
}

show_health_score() {
    local score=$(calculate_health_score)

    section "Health Score"

    echo -e "${CYAN}╔════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}   Agent Tooling Health Score      ${CYAN}║${NC}"
    echo -e "${CYAN}╠════════════════════════════════════╣${NC}"

    if [ $score -ge 90 ]; then
        echo -e "${CYAN}║${NC}         ${GREEN}${score}%${NC} - EXCELLENT ✓        ${CYAN}║${NC}"
    elif [ $score -ge 70 ]; then
        echo -e "${CYAN}║${NC}         ${YELLOW}${score}%${NC} - GOOD ⚠            ${CYAN}║${NC}"
    elif [ $score -ge 50 ]; then
        echo -e "${CYAN}║${NC}         ${YELLOW}${score}%${NC} - NEEDS WORK ⚠      ${CYAN}║${NC}"
    else
        echo -e "${CYAN}║${NC}         ${RED}${score}%${NC} - CRITICAL ✗        ${CYAN}║${NC}"
    fi

    echo -e "${CYAN}╠════════════════════════════════════╣${NC}"
    echo -e "${CYAN}║${NC}  ✓ Passed:   ${GREEN}${CHECKS_PASSED}${NC}                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ⚠ Warnings: ${YELLOW}${CHECKS_WARNING}${NC}                  ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  ✗ Failed:   ${RED}${CHECKS_FAILED}${NC}                  ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════╝${NC}"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║   Agent Tooling Doctor v${VERSION}                    ║"
    echo "║   Diagnostic & Health Check System                    ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""

    # Parse arguments
    AUTO_FIX=false
    RUN_AI_DIAGNOSTICS=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto-fix)
                AUTO_FIX=true
                shift
                ;;
            --ai)
                RUN_AI_DIAGNOSTICS=true
                shift
                ;;
            --help)
                echo "Usage: agent-tools-doctor.sh [options]"
                echo ""
                echo "Options:"
                echo "  --auto-fix    Attempt automatic fixes for detected issues"
                echo "  --ai          Run AI-powered diagnostic analysis (requires gptme)"
                echo "  --help        Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    # Run all diagnostic checks
    check_python_version
    check_nodejs
    check_core_tools
    check_optional_tools
    check_git_repo
    check_project_structure
    check_api_keys
    check_dependencies
    check_disk_space
    test_tool_functionality
    check_external_repo_status
    check_version_compatibility

    # AI diagnostics if requested
    if [ "$RUN_AI_DIAGNOSTICS" = "true" ]; then
        run_ai_diagnostics
    fi

    # Show results
    echo ""
    show_health_score
    echo ""
    suggest_fixes

    # Exit with appropriate code
    if [ $CHECKS_FAILED -gt 0 ]; then
        echo ""
        error "Some checks failed. Please review and fix issues above."
        exit 1
    elif [ $CHECKS_WARNING -gt 0 ]; then
        echo ""
        warn "All critical checks passed, but some warnings were found."
        exit 0
    else
        echo ""
        success "All checks passed! Your agent tooling setup is healthy."
        exit 0
    fi
}

main "$@"
