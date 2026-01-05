# Pre-Commit Checklist

**Use this before every commit to avoid pushing inception/dogfooding work**

## ✅ What to Check Before Committing

### 1. Review Staged Files
```bash
git status
git diff --staged --name-only
```

**Look for:**
- ❌ `test_*.py` - Test scripts
- ❌ `use_*.py` - Helper scripts
- ❌ `document_*.py` - Session documentation scripts
- ❌ `*_session.py` - Session helpers
- ❌ `.env` files - API keys
- ❌ Any temporary/helper scripts

### 2. Verify What's Being Committed
```bash
# See full diff
git diff --staged

# Check for secrets
git diff --staged | grep -i "api.*key\|secret\|password\|token"
```

### 3. Remove Unwanted Files
```bash
# Unstage specific file
git restore --staged <filename>

# Or unstage all and start over
git reset
```

### 4. Safe to Commit Checklist

- [ ] Only actual project code/docs/tests are staged
- [ ] No helper scripts (test_*.py, use_*.py, etc.)
- [ ] No API keys or secrets
- [ ] No `.env` files
- [ ] No temporary files
- [ ] Beads database updates are intentional (track real project work)

### 5. Double-Check Before Push
```bash
# See what will be pushed
git log origin/main..HEAD --oneline

# Review the commits
git show HEAD --stat
```

## 🚨 Common Mistakes to Avoid

1. **Committing helper scripts** used during dogfooding
   - Scripts that call Mem0, Empirica directly
   - Test/experiment scripts
   - Session documentation helpers

2. **Committing API keys**
   - `.env` files
   - Hardcoded keys in scripts

3. **Committing inception work**
   - The `/agent-tooling-setup/` subdirectory
   - Any scripts showing "how we used the tools to improve the tools"

## ✅ What IS Safe to Commit

- ✅ Core project code (`install.sh`, `agent-tools-doctor.sh`, etc.)
- ✅ Documentation (`README.md`, `docs/`, `AGENTS.md`, etc.)
- ✅ Templates (`agent-tools.yaml.template`, `.env.template`)
- ✅ Beads database (`.beads/beads.db`) - tracks project tasks
- ✅ Configuration files for project setup
- ✅ Tests that are part of the project (not dogfooding tests)

## Example: Good vs Bad

### ❌ BAD - Don't Commit
```bash
git add test_mem0_platform.py    # Helper script
git add use_mem0.py               # Session script
git add document_session.py       # Dogfooding script
git add .env                      # Has API keys!
```

### ✅ GOOD - Safe to Commit
```bash
git add AGENTS.md                 # Project docs
git add docs/guides/MEM0-GUIDE.md # User-facing guide
git add agent-tools-quickstart.sh # Project script
git add .beads/beads.db           # Task tracking
```

## Quick Command to Check

```bash
# See what would be committed
git status --short

# M = modified
# A = new file
# ?? = untracked

# Review each M or A file - is it project code or helper script?
```

## Remember

**When in doubt, DON'T commit it!**

You can always add it later if needed. It's much harder to remove something after it's pushed.
