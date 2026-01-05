# AI Tools Usage Guide

**Complete guide to using gptme, aider, and opencommit with agent-tooling-setup**

## Overview

This project includes three powerful AI coding assistants that work together:

- **gptme** - Terminal AI agent for exploration and prototyping
- **aider** - AI pair programmer for focused code changes
- **opencommit** - AI-generated commit messages

All tools are configured in [.agent-tools.yaml](../../.agent-tools.yaml) and work seamlessly with Beads, Perles, and Empirica.

## Quick Reference

| Tool | Best For | Command | Cost |
|------|----------|---------|------|
| **gptme** | Exploration, prototyping, terminal tasks | `gptme` | Low-Moderate |
| **aider** | Focused code edits, refactoring | `aider` | Moderate-High |
| **opencommit** | Commit messages | `oco` | Very Low |

## gptme - Terminal AI Agent

### What is gptme?

A conversational AI assistant that runs in your terminal with access to:
- Shell commands
- File operations
- Web browsing (with browser extra)
- Data analysis (with datascience extra)
- Web UI server (with server extra)

### When to Use

✅ **Good for:**
- Exploring unfamiliar codebases
- Running complex command sequences
- Data analysis and visualization
- Prototyping new features
- Debugging with interactive feedback

❌ **Not ideal for:**
- Making many file edits (use aider)
- Production code changes (less precise than aider)

### Basic Usage

```bash
# Start interactive session
gptme

# Continue previous session
gptme --resume

# Start with a specific task
gptme "analyze the test coverage in this project"

# Use with Beads context
gptme "check status of task agent-tooling-setup-ad9"
```

### Example Workflow

```bash
# Start session
gptme

# In gptme session:
> Show me the structure of the install.sh script
> What are the main functions in agent-tools-doctor.sh?
> Run the test suite and summarize failures
> Create a script to automate the update process
```

### Configuration

gptme is configured in `.agent-tools.yaml` with these extras:
- `browser`: Web browsing with Playwright
- `datascience`: pandas, matplotlib, numpy
- `server`: Flask web interface

Config location: `~/.config/gptme/config.toml`

### Tips

- Use `gptme --help` to see all options
- Session logs saved to `~/.local/share/gptme/logs`
- Use `/help` within gptme for in-session commands
- Use `/save` to save important outputs

## aider - AI Pair Programmer

### What is aider?

An AI pair programmer that:
- Understands your entire codebase
- Makes precise, targeted edits
- Creates structured git commits
- Supports multiple file editing

### When to Use

✅ **Good for:**
- Implementing well-defined features
- Refactoring existing code
- Fixing specific bugs
- Making changes across multiple files

❌ **Not ideal for:**
- Exploration (use gptme)
- Learning a new codebase
- Tasks requiring shell access

### Basic Usage

```bash
# Start aider
aider

# Start with specific files
aider install.sh agent-tools-doctor.sh

# Add files during session
# /add filename.py

# Make changes
# "Add error handling to the install function"

# Review changes before committing
# /diff

# Commit changes
# /commit

# Exit
# /exit
```

### Safety Features

Configured in `.agent-tools.yaml`:
- `auto_commit: false` - Manual commit control
- `require_confirmation: true` - Ask before operations
- `backup_before_edit: true` - Auto-stash protection

### Example Workflow with Beads

```bash
# Get task details
bd show agent-tooling-setup-ad9

# Update task status
bd update agent-tooling-setup-ad9 --status in_progress

# Start aider with relevant files
aider install.sh

# In aider session:
> Add detection for gptme, aider, and opencommit installations
> Check if they're in PATH and report versions
> Add to the "What Gets Installed" section

# Review changes
/diff

# Run tests if needed
/run ./agent-tools-doctor.sh

# Commit (or use opencommit later)
/commit

# Update Beads
bd close agent-tooling-setup-ad9
```

### Configuration

Config location: `~/.aider.conf.yml`

Key settings:
```yaml
model: gpt-4o
dark-mode: true
auto-commits: false
dirty-commits: false
```

### Tips

- Use `/help` to see all commands
- Use `/add` to add files to context
- Use `/drop` to remove files
- Use `/clear` to clear chat history
- Use `/undo` to revert last change
- Use `/tokens` to check token usage (important for cost!)

## opencommit - AI Commit Messages

### What is opencommit?

Generates conventional commit messages using AI by analyzing your staged changes.

### When to Use

✅ **Good for:**
- Every commit!
- Ensuring consistent commit message style
- Describing complex changesets

❌ **Manual commit when:**
- Very simple changes ("fix typo")
- You want a specific message format

### Basic Usage

```bash
# Stage your changes
git add .

# Generate commit message and commit
oco

# Generate message but review before committing
oco --dry-run

# Use with specific files
git add file1.js file2.js
oco
```

### Configuration

Configured in `.agent-tools.yaml`:
```yaml
opencommit:
  enabled: true
  config:
    ai_provider: "openai"
    model: "gpt-4o-mini"
    commit_style: "conventional"
    description: true
    emoji: false
```

Config location: `~/.opencommit`

### Example Workflow

```bash
# Make changes
# ... edit files ...

# Stage changes
git add install.sh docs/guides/AI-TOOLS-GUIDE.md

# Generate and commit
oco

# Example output:
# feat(install): add AI tools version detection
#
# - Add gptme, aider, opencommit version checks
# - Report installation status in installer
# - Update documentation with usage guide
```

### Tips

- Run `oco config` to change settings
- Use `oco config set OCO_LANGUAGE=en` for English
- Use `oco config set OCO_EMOJI=true` for gitmoji
- Very cheap to use (~$0.001 per commit)

## Integrated Workflow

### Complete Development Session

Here's how to use all tools together in a typical session:

#### 1. Start Session

```bash
# Create Empirica session
empirica session-create --ai-id my-session --output json

# Check available work
bd ready

# Claim a task
bd update agent-tooling-setup-abc --status in_progress
```

#### 2. Explore with gptme

```bash
# Use gptme to understand the task
gptme "explain how install.sh works and where to add AI tools detection"

# Let gptme suggest an approach
# > What's the best place to add tool version checks?
# > Show me similar detection code in the project
# > Draft the detection function

# Save key findings
# /save detection-plan.md
```

#### 3. Implement with aider

```bash
# Take gptme's suggestions to aider
aider install.sh agent-tools-doctor.sh

# Implement the feature
# > Add functions to detect gptme, aider, and opencommit
# > Add version reporting for each tool
# > Update the installer output to show AI tools status

# Test the changes
/run ./install.sh --dry-run

# Review before committing
/diff

# Exit without committing (we'll use opencommit)
/exit
```

#### 4. Commit with opencommit

```bash
# Stage all changes
git add install.sh agent-tools-doctor.sh

# Generate AI commit message
oco

# Push changes
git push
```

#### 5. Complete Task

```bash
# Update Beads
bd close agent-tooling-setup-abc

# View board
perles

# Sync Beads with git
bd sync
```

### Cost Management

Approximate costs per operation:

| Operation | Tokens | Cost (GPT-4o) | Cost (GPT-4o-mini) |
|-----------|--------|---------------|-------------------|
| gptme query | 1K-10K | $0.01-$0.10 | $0.001-$0.01 |
| aider edit (small) | 5K-20K | $0.05-$0.20 | $0.005-$0.02 |
| aider edit (large) | 20K-100K | $0.20-$1.00 | $0.02-$0.10 |
| opencommit | 500-2K | $0.005-$0.02 | $0.0005-$0.002 |

**Tips to reduce costs:**
- Use gptme with cheaper models for exploration
- Use aider only on specific files, not whole codebase
- Configure gptme/aider to use gpt-4o-mini for simple tasks
- Review `/tokens` in aider before big operations

## Troubleshooting

### gptme Issues

```bash
# Reset configuration
rm ~/.config/gptme/config.toml
gptme

# Check logs
tail -f ~/.local/share/gptme/logs/*/conversation.json

# Update to latest
pipx upgrade gptme
```

### aider Issues

```bash
# Check configuration
cat ~/.aider.conf.yml

# Clear chat history
aider --clear-chat-history

# Update to latest
pipx upgrade aider-chat

# Check token usage
aider --tokens
```

### opencommit Issues

```bash
# Reconfigure
oco config

# Check config
cat ~/.opencommit

# Update to latest
npm update -g opencommit

# Test without committing
oco --dry-run
```

### API Key Issues

All tools need API keys. Set in environment or `.env`:

```bash
# Required for OpenAI
export OPENAI_API_KEY=sk-...

# Required for Anthropic (if using Claude)
export ANTHROPIC_API_KEY=sk-ant-...

# Add to .env file (don't commit!)
echo "OPENAI_API_KEY=sk-..." >> .env
echo "ANTHROPIC_API_KEY=sk-ant-..." >> .env
```

## Best Practices

### 1. Use the Right Tool

- **Exploring?** → gptme
- **Coding?** → aider
- **Committing?** → opencommit

### 2. Stay in Control

- Review all AI changes before committing
- Use `--dry-run` and preview features
- Keep `auto_commit: false` in config

### 3. Track Your Work

```bash
# Always use Beads for task tracking
bd create "Task description"
bd update task-id --status in_progress
# ... work with AI tools ...
bd close task-id
bd sync
```

### 4. Document Learning

After using AI tools to solve something:
```bash
# Document what you learned
echo "Learned: AI tools work best when..." | empirica postflight-submit -
```

### 5. Cost Awareness

- Check `/tokens` in aider before large operations
- Use cheaper models (gpt-4o-mini) for simple tasks
- Limit aider to specific files, not entire codebase

## Examples

### Example 1: Adding a New Feature

```bash
# 1. Create and claim task
bd create "Add health check endpoint" --priority P1
bd update agent-tooling-setup-xyz --status in_progress

# 2. Explore with gptme
gptme "show me how other health checks are implemented"

# 3. Implement with aider
aider server.py routes.py
# > Add /health endpoint that checks all tool availability

# 4. Commit with opencommit
git add server.py routes.py tests/test_health.py
oco

# 5. Complete
bd close agent-tooling-setup-xyz
bd sync
```

### Example 2: Debugging an Issue

```bash
# 1. Use gptme to investigate
gptme "reproduce the install.sh error and analyze logs"

# 2. Once root cause found, use aider
aider install.sh
# > Fix the PATH detection to handle spaces in directory names

# 3. Test
./install.sh --dry-run

# 4. Commit
git add install.sh
oco

# 5. Update task
bd close agent-tooling-setup-bug123
```

### Example 3: Refactoring

```bash
# 1. Use aider for precise refactoring
aider utils.py helpers.py

# In aider:
# > Extract duplicate validation logic into validate_config()
# > Update all callers to use the new function
# > Add error handling

# 2. Review changes
/diff

# 3. Run tests
/run pytest tests/

# 4. Commit
git add utils.py helpers.py tests/
oco
```

## Learn More

- **gptme**: https://github.com/ErikBjare/gptme
- **aider**: https://aider.chat/
- **opencommit**: https://github.com/di-sukharev/opencommit

## Quick Start Checklist

- [ ] API keys configured (`.env` file)
- [ ] Tools installed and in PATH
- [ ] Test each tool: `gptme --version`, `aider --version`, `oco --version`
- [ ] Read this guide
- [ ] Try the integrated workflow example
- [ ] Create your first task with `bd create`
- [ ] Use all three tools together!

---

**Remember**: These are powerful tools. Always review AI-generated code before committing!
