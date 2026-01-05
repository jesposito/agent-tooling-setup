# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd onboard` to get started.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --status in_progress  # Claim work
bd close <id>         # Complete work
bd sync               # Sync with git
```

## Session Workflow with Mem0 (Optional)

If you have Mem0 configured (see [docs/guides/MEM0-GUIDE.md](docs/guides/MEM0-GUIDE.md)):

**Start of Session:**
```python
from mem0 import MemoryClient
import os

client = MemoryClient(api_key=os.getenv('MEM0_API_KEY'))
user_id = "agent-tooling-setup"

# Recall previous context
results = client.search(
    query="What was I working on? What decisions were made?",
    user_id=user_id,
    filters={"user_id": user_id},
    limit=5
)

for mem in results['results']:
    print(f"  - {mem['memory']}")
```

**During Work:**
```python
# Store key decisions or learnings
client.add(
    messages=[{"role": "user", "content": "Decided to use X approach because Y"}],
    user_id=user_id
)
```

**End of Session:**
```python
# Document what was accomplished
client.add(
    messages=[{"role": "user", "content": "Completed task ABC. Key learning: XYZ"}],
    user_id=user_id
)
```

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**CRITICAL: What NOT to Commit**
- ❌ Helper scripts used during development (`test_*.py`, `use_*.py`, etc.)
- ❌ Temporary Python/shell scripts created for the session
- ❌ API keys or `.env` files with secrets
- ❌ Dogfooding/inception work (tools used to improve the tools)
- ✅ ONLY commit the actual project improvements (code, docs, tests)

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Review what's being committed** - Check `git status` and `git diff --staged`
   - Remove any helper/temp scripts: `git restore --staged <file>`
   - Verify no API keys or secrets
4. **Update issue status** - Close finished work, update in-progress items
5. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd sync
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

