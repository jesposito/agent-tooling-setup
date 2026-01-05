# Installation via Claude Code

If you have **Claude Code** installed in VS Code, you can set this up with a simple prompt!

## 🤖 One-Prompt Installation

Just ask Claude Code:

```
Install the agent tooling setup from https://github.com/jesposito/agent-tooling-setup

Run the installer to set up Empirica, Beads, and Perles for this project.
```

That's it! Claude will:
1. ✅ Clone/download the installer
2. ✅ Run it in your project
3. ✅ Set up all configuration files
4. ✅ Initialize Beads
5. ✅ Create `.claude/CLAUDE.md` and `AGENTS.md`

## 🎯 Alternative: More Specific Prompt

For more control, use this detailed prompt:

```
Please help me install the agent tooling setup:

1. Download the installer from:
   https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh

2. Run it with the --with-agent-instructions flag to create the full
   agent-instructions.md template

3. After installation, show me what files were created and explain
   the integrated workflow

Repository: https://github.com/jesposito/agent-tooling-setup
```

## 📋 What Claude Will Install

After running the prompt, Claude will set up:

```
your-project/
├── .beads/               # Task tracking database
│   ├── beads.db
│   └── config.yaml
├── .claude/
│   └── CLAUDE.md        # Quick reference (Claude reads this!)
├── AGENTS.md            # Workflow checklist
├── .gitattributes       # Git merge strategy
└── agent-instructions.md # Full guidelines (if requested)
```

Plus install the tools (if not present):
- **bd** (Beads) - Task tracking CLI
- **perles** - Terminal UI for Beads
- **empirica** - Epistemic assessment

## 🔄 Using with Claude Code

Once installed, Claude Code will automatically see:

1. **`.claude/CLAUDE.md`** - Quick reference showing available tools
2. **`AGENTS.md`** - Workflow and session completion checklist
3. **`agent-instructions.md`** - Full development guidelines (if created)

Claude will then know to:
- ✅ Use `bd` for task tracking instead of TODO comments
- ✅ Run `empirica` to track learning across sessions
- ✅ Follow the integrated workflow
- ✅ Complete the "landing the plane" checklist before ending sessions

## 💡 Example: Starting a Session with Claude

After installation, start your session like this:

```
I'm starting work on [feature name].

Please:
1. Create an Empirica session
2. Check what tasks are ready (bd ready)
3. Help me plan the implementation
```

Claude will:
1. Run `empirica session-create`
2. Check `bd ready` for available tasks
3. Create new beads for the work
4. Track progress as you go

## 🎯 Example: Ending a Session with Claude

When you're done:

```
I'm wrapping up this session. Please follow the AGENTS.md checklist
to land the plane properly.
```

Claude will:
1. Close completed beads
2. Run `bd sync`
3. Run `empirica postflight-submit`
4. Commit and push changes
5. Verify everything is clean

## 🧪 Testing the Setup

Ask Claude:

```
Verify the agent tooling setup is working correctly:
1. Check that bd is installed (bd version)
2. Check that empirica is installed (empirica --version)
3. Show me the .beads/ directory structure
4. Show me what's in .claude/CLAUDE.md
```

## 🆘 Troubleshooting with Claude

If something doesn't work:

```
The agent tooling installation seems incomplete. Can you:
1. Check what's installed (bd version, empirica --version, perles --version)
2. Look for error messages in the installation output
3. Re-run the installer if needed
4. Verify the .claude/CLAUDE.md and AGENTS.md files exist
```

## 📚 What Makes This Different?

**Without this setup:**
- Claude forgets context between sessions
- TODOs scattered in markdown files
- No structured task tracking
- Manual workflow management

**With this setup:**
- ✅ Claude has persistent memory (Empirica)
- ✅ Structured task tracking (Beads)
- ✅ Visual kanban boards (Perles)
- ✅ Automated workflow
- ✅ Claude auto-follows best practices from `AGENTS.md`

## 🎓 Learning More

After installation, ask Claude:

```
Explain the integrated workflow from .claude/CLAUDE.md and show me
how to use Empirica, Beads, and Perles together.
```

Claude will read the configuration files and explain the workflow!

## 🔄 Using in Multiple Projects

Once you've seen it work in one project, you can add it to others:

```
Add the agent tooling setup to this project using the installer from
https://github.com/jesposito/agent-tooling-setup
```

Works in **any** git repository!

---

**Note**: This assumes you have [Claude Code](https://claude.ai/claude-code) installed. If not, see the main [README.md](README.md) for manual installation instructions.
