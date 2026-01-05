# Integration Workflow Example

**Real-world example of using all tools together: gptme + aider + opencommit + Beads + Empirica**

This example shows a complete development session using all the agent tooling features together.

## Scenario

You need to add a new feature: "Export tasks to JSON format in the Beads CLI"

## Complete Workflow

### 1. Start the Session

```bash
# Create Empirica tracking session
empirica session-create --ai-id add-export-feature --output json
# Output: {"session_id": "abc-123", ...}

# Check what work is available
bd ready

# Create the task
bd create "Add JSON export to Beads tasks" --priority P1
# Output: agent-tooling-setup-xyz

# Mark as in progress
bd update agent-tooling-setup-xyz --status in_progress
```

### 2. Explore with gptme

Use gptme to understand the codebase and plan the approach:

```bash
# Start interactive gptme session
gptme

# In gptme session:
> Show me the structure of the beads CLI commands
> Where would I add a new export command?
> What format do other export commands use?
> Draft a function signature for JSON export
> Create a test script to validate the JSON output

# Save the plan
> /save export-plan.md
```

**What gptme discovered:**
- Beads uses a plugin system for commands
- Export commands are in `cmd/export/`
- JSON marshaling should use Go's `encoding/json`
- Tests should go in `cmd/export/json_test.go`

### 3. Implement with aider

Take gptme's findings and use aider for precise code changes:

```bash
# Start aider with the relevant files
aider cmd/export/json.go cmd/export/json_test.go

# In aider session:
> Create a JSON export command that outputs tasks in JSON format
> Include fields: id, title, status, priority, created, updated
> Add proper error handling for file I/O
> Include tests for valid and invalid cases

# Review the changes
> /diff

# Run tests
> /run go test ./cmd/export/...

# If tests pass, exit (don't commit yet - we'll use opencommit)
> /exit
```

**What aider created:**
- `cmd/export/json.go` - JSON export implementation
- `cmd/export/json_test.go` - Comprehensive tests
- Updated `cmd/root.go` - Registered new command

### 4. Test the Feature

```bash
# Try the new command
bd export --format json --output tasks.json

# Validate the output
cat tasks.json | jq '.'

# Run all tests
go test ./...
```

### 5. Commit with opencommit

```bash
# Stage all changes
git add cmd/export/json.go cmd/export/json_test.go cmd/root.go

# Generate AI commit message
oco

# Output (example):
# feat(export): add JSON export format for tasks
#
# - Implement bd export --format json command
# - Add comprehensive test coverage
# - Register command in root CLI
# - Support custom output file path
```

### 6. Update Documentation

```bash
# Use gptme to draft documentation
gptme "generate usage examples for the new JSON export feature"

# Review and add to docs
aider docs/commands/export.md
> Add the JSON export examples from gptme
> /commit
```

### 7. Complete the Task

```bash
# Close the task
bd close agent-tooling-setup-xyz

# Update other tasks if needed
bd create "Add CSV export format" --priority P2

# Sync with git
bd sync

# Push everything
git push

# View your progress
perles
```

## Detailed Breakdown

### gptme Phase (Exploration)

**Purpose**: Understand, explore, plan
**Duration**: 5-10 minutes

```bash
gptme
```

**Sample conversation:**

```
You: Explain how the Beads export system works

gptme: The Beads export system is built around...
[explanation of architecture]

You: Show me an example of an existing export format

gptme: Here's the CSV export implementation:
[shows code with explanations]

You: What's the best way to add JSON export?

gptme: You should:
1. Create cmd/export/json.go
2. Implement the Export interface
3. Register in cmd/root.go
[detailed plan]

You: /save json-export-plan.md
```

**Benefits:**
- No token waste on failed edits
- Get architectural understanding
- Identify all files that need changes
- Create a clear plan before coding

### aider Phase (Implementation)

**Purpose**: Make precise, tested code changes
**Duration**: 10-20 minutes

```bash
aider cmd/export/json.go cmd/export/json_test.go cmd/root.go
```

**Sample conversation:**

```
You: Implement JSON export based on the plan in json-export-plan.md

aider: I'll implement the JSON export functionality...
[creates code]

You: Add error handling for invalid output paths

aider: I've added comprehensive error handling...
[updates code]

You: /run go test ./cmd/export

aider: Running tests...
✓ All tests passed

You: /diff

aider: Here are the changes:
[shows unified diff]

You: Looks good, /exit
```

**Benefits:**
- Precise, targeted edits
- Built-in testing
- Full codebase context
- Reviewable before committing

### opencommit Phase (Committing)

**Purpose**: Generate consistent, descriptive commits
**Duration**: 30 seconds

```bash
git add cmd/export/json.go cmd/export/json_test.go cmd/root.go
oco
```

**Output:**

```
feat(export): add JSON export format for tasks

- Implement bd export --format json command
- Add marshaling for task fields: id, title, status, priority, timestamps
- Include comprehensive test coverage for valid/invalid cases
- Register new command in root CLI
- Support custom output file path via --output flag

Allows users to export their task list in JSON format for integration
with other tools and workflows.
```

**Benefits:**
- Consistent conventional commits
- Detailed descriptions automatically
- No time spent writing commit messages
- Perfect for CI/CD and changelog generation

## Cost Analysis

For this complete feature (from planning to commit):

| Phase | Tool | Tokens | Cost (GPT-4o) | Cost (GPT-4o-mini) |
|-------|------|--------|---------------|-------------------|
| Exploration | gptme | ~8,000 | ~$0.08 | ~$0.008 |
| Implementation | aider | ~25,000 | ~$0.25 | ~$0.025 |
| Documentation | aider | ~5,000 | ~$0.05 | ~$0.005 |
| Commits (2x) | opencommit | ~2,000 | ~$0.02 | ~$0.002 |
| **Total** | | **~40,000** | **~$0.40** | **~$0.04** |

**Time saved**: ~2-3 hours of manual work
**ROI**: Excellent (even with GPT-4o)

## Best Practices Demonstrated

### 1. Right Tool for Right Job

- ❌ Don't use aider for exploration (wastes tokens)
- ✅ Use gptme to understand, aider to implement

### 2. Stay in Control

- Review all AI changes with `/diff`
- Run tests before committing
- Use Beads for tracking progress

### 3. Cost Awareness

- gptme for cheap exploration
- aider with specific files only (not whole codebase)
- opencommit is dirt cheap - use it every time

### 4. Documentation Tracking

```bash
# Always track what you're doing
bd update task-id --status in_progress
# ... work with AI tools ...
bd close task-id
bd sync
```

## Common Patterns

### Pattern 1: Bug Fix Workflow

```bash
# 1. Investigate with gptme
gptme "reproduce the authentication bug and find root cause"

# 2. Fix with aider
aider auth/login.go auth/session.go
# > Fix the token expiration bug identified by gptme

# 3. Commit
git add auth/
oco

# 4. Update Beads
bd close bug-task-id
```

### Pattern 2: Refactoring Workflow

```bash
# 1. Plan with gptme
gptme "analyze utils.go and suggest refactoring to improve testability"

# 2. Refactor with aider
aider utils.go utils_test.go
# > Extract validation logic into separate functions
# > Add unit tests for each function

# 3. Verify
./run-tests.sh

# 4. Commit
git add utils.go utils_test.go
oco
```

### Pattern 3: New Feature Workflow

```bash
# 1. Research with gptme
gptme "show me how rate limiting is implemented in similar CLI tools"

# 2. Design with gptme
gptme "draft an interface for rate limiting in this codebase"

# 3. Implement with aider
aider ratelimit/limiter.go ratelimit/limiter_test.go
# > Implement the rate limiter based on gptme's design

# 4. Integrate with aider
aider cmd/api/server.go
# > Add rate limiting middleware to API endpoints

# 5. Document
aider docs/api/rate-limiting.md
# > Add usage guide for rate limiting

# 6. Commit each logical piece
git add ratelimit/
oco
git add cmd/api/server.go
oco
git add docs/
oco
```

## Troubleshooting

### gptme session gets expensive

**Problem**: Token usage climbing in gptme

**Solution**:
```bash
# Start fresh session
> /clear
# Or exit and restart
> /exit
gptme
```

### aider making wrong changes

**Problem**: aider doesn't understand what you want

**Solution**:
```bash
# Be more specific, reference files
> Look at json-export-plan.md and implement exactly that plan

# Or undo and try again
> /undo
> [rephrase request]
```

### opencommit generates poor messages

**Problem**: Commit message doesn't capture changes well

**Solution**:
```bash
# Review with --dry-run first
oco --dry-run

# If bad, write manual commit
git commit -m "your message"

# Or stage changes in smaller logical chunks
git add file1.go
oco
git add file2.go
oco
```

## Advanced: Parallel Workflows

Work on multiple tasks simultaneously:

```bash
# Terminal 1: Bug fix with aider
bd update bug-123 --status in_progress
aider auth/login.go

# Terminal 2: Explore new feature with gptme
bd update feat-456 --status in_progress
gptme "research rate limiting approaches"

# Terminal 3: Monitor progress
watch -n 5 bd list

# Terminal 4: View board
perles
```

## Key Takeaways

1. **Use all tools together** - Each has a specific strength
2. **gptme first** - Cheap exploration before expensive implementation
3. **aider for code** - Precise, tested changes
4. **opencommit always** - Consistent commit messages
5. **Beads for tracking** - Never lose track of work
6. **Review everything** - AI is powerful but not perfect

## See Also

- [AI Tools Guide](../guides/AI-TOOLS-GUIDE.md) - Detailed guide for each tool
- [Quick Start](../guides/QUICKSTART.md) - Getting started
- [AGENTS.md](../../AGENTS.md) - Session completion checklist

---

**Try it yourself!** Pick a small feature and follow this workflow.
