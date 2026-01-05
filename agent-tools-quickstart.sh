#!/usr/bin/env bash
# Agent Tooling Quickstart
# Interactive guide for first session with agent-tooling-setup

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
header() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}\n"; }

clear

cat << 'EOF'
╔════════════════════════════════════════════════════════╗
║   Agent Tooling Quickstart                            ║
║   Your First Session with AI-Assisted Development     ║
╚════════════════════════════════════════════════════════╝

This interactive guide will walk you through:
  1. Starting an Empirica session (epistemic tracking)
  2. Creating your first Beads task
  3. Working with the task
  4. Completing the session properly

Press ENTER to continue...
EOF

read -r

# Step 1: Check tools
header "Step 1: Verify Tools"

if ! command -v bd &> /dev/null; then
    echo "❌ Beads (bd) not found. Please run install.sh first."
    exit 1
fi
success "Beads installed"

if ! command -v empirica &> /dev/null; then
    echo "⚠️  Empirica not found. Skipping epistemic tracking."
    SKIP_EMPIRICA=true
else
    success "Empirica installed"
fi

if ! command -v perles &> /dev/null; then
    info "Perles not found (optional visualization tool)"
fi

# Step 2: Start Empirica session
if [ "$SKIP_EMPIRICA" != "true" ]; then
    header "Step 2: Start Empirica Session"
    info "Empirica tracks what you know and learn during the session."
    echo ""

    read -p "Enter AI/Agent ID (default: my-first-session): " ai_id
    ai_id=${ai_id:-my-first-session}

    info "Creating session..."
    session_info=$(empirica session-create --ai-id "$ai_id" --output json 2>/dev/null || echo "{}")
    session_id=$(echo "$session_info" | grep -o '"session_id":"[^"]*"' | cut -d'"' -f4 || echo "")

    if [ -n "$session_id" ]; then
        success "Session created: $session_id"
        echo ""
        echo "Optional: Document what you know at the start:"
        echo "  empirica preflight-submit --session-id $session_id --vectors -"
        echo "  (Type your knowledge, then Ctrl+D)"
        echo ""
    else
        echo "⚠️  Could not create session. Continuing anyway..."
    fi
else
    header "Step 2: Empirica (Skipped)"
    info "Install Empirica later: pip install --user git+https://github.com/Nubaeon/empirica.git"
fi

read -p "Press ENTER to continue..."

# Step 3: Check existing work
header "Step 3: Check Available Work"

info "Checking for existing tasks..."
bd ready || true

echo ""
read -p "Create a new task? (Y/n): " create_task
create_task=${create_task:-Y}

if [[ "$create_task" =~ ^[Yy] ]]; then
    echo ""
    read -p "Task title: " task_title

    if [ -n "$task_title" ]; then
        task_output=$(bd create "$task_title" --priority P1 2>&1)
        task_id=$(echo "$task_output" | grep -o 'agent-tooling-setup-[a-z0-9]*' | head -1)

        if [ -n "$task_id" ]; then
            success "Created task: $task_id"
            NEW_TASK_ID="$task_id"
        fi
    fi
fi

# Step 4: Start working
header "Step 4: Start Working"

if [ -n "$NEW_TASK_ID" ]; then
    info "Claiming task $NEW_TASK_ID..."
    bd update "$NEW_TASK_ID" --status in_progress
    success "Task is now in progress!"
else
    read -p "Enter task ID to work on (or ENTER to skip): " task_id
    if [ -n "$task_id" ]; then
        bd update "$task_id" --status in_progress || true
    fi
fi

echo ""
info "💡 Workflow tips:"
echo "  • View task: bd show <id>"
echo "  • Update task: bd update <id> --status <status>"
echo "  • Add notes: bd update <id> --notes 'Your notes'"
echo "  • Visual board: perles (if installed)"

read -p "Press ENTER to continue..."

# Step 5: Completing work
header "Step 5: Complete Session (Important!)"

cat << 'EOF'
When you finish working, you MUST:

1. Complete your tasks:
   bd close <task-id>

2. Sync with git:
   bd sync

3. PUSH to remote (MANDATORY):
   git push

4. Optional - Document learnings:
   echo "Learned: XYZ" | empirica postflight-submit --session-id <id> --vectors -

Press ENTER for a checklist...
EOF

read -r

header "Session Completion Checklist"

checklist=(
    "Finish work on tasks"
    "Run tests/linters (if code changed)"
    "Close completed tasks: bd close <id>"
    "Create tasks for follow-up work"
    "Sync Beads: bd sync"
    "PUSH to remote: git push"
    "Document learnings (optional): empirica postflight"
)

for item in "${checklist[@]}"; do
    echo "  ☐ $item"
done

echo ""
success "Quickstart complete!"
echo ""
info "📚 Next steps:"
echo "  • Read docs/DEVELOPMENT.md for detailed workflow"
echo "  • Read AGENTS.md for session completion rules"
echo "  • Explore docs/guides/ for AI tools integration"
echo ""
info "🎯 Remember: Work isn't done until 'git push' succeeds!"
echo ""
EOF

chmod +x agent-tools-quickstart.sh
