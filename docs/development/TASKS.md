# Agent Tooling Setup - Self-Improvement Tasks

**Project**: Using agent-tooling-setup to improve itself! 🚀

## Status Legend
- 🔴 Blocked
- 🟡 In Progress
- 🟢 Done

## Current Tasks

### 🟢 Repository Cleanup
- [x] Remove all dot files/directories from GitHub
- [x] Reorganize file structure (docs/, templates/, etc.)
- [x] Fix .gitignore to ignore ALL dot files
- [x] Update all documentation references

### 🟢 Installation Script Debugging
- [x] Identify "frozen" installation issue
- [x] Fix output suppression in install-global.sh
- [x] Add progress indicators for long installs
- [x] Add time estimates for users

### 🟡 Windows Compatibility
- [ ] Document Windows limitations (Beads, Perles unavailable)
- [ ] Create Windows-specific installation guide
- [ ] Add fallback for Windows users (empirica-only mode?)
- [ ] Test on WSL instead of Git Bash

### 🔴 Tool Installation Issues (Blocked on Windows)
- [ ] Beads: "Unsupported operating system: MINGW64_NT"
- [ ] Perles: Likely same issue
- [ ] Empirica: Installed but not in PATH

### 📋 Next Priorities
1. **Test on WSL** - The tools should work there
2. **Windows fallback mode** - Skip Beads/Perles, use only Empirica
3. **Better platform detection** - Detect Windows early, warn users
4. **Alternative task tracking** - docs/development/TASKS.md instead of Beads for Windows users

## Ideas for Improvement
- [ ] Interactive installation wizard (asks which tools to install)
- [ ] Platform-specific install scripts
- [ ] Add Windows-native alternatives (GitHub Projects API integration?)
- [ ] Better error messages with suggestions
- [ ] Add `--platform` flag to force/skip platform checks

## Testing Needed
- [ ] Test on Linux
- [ ] Test on macOS
- [ ] Test on WSL2
- [ ] Test global vs per-project modes
- [ ] Test migration scripts

## Documentation Improvements
- [ ] Add troubleshooting section for common Windows issues
- [ ] Create video walkthrough
- [ ] Add screenshots to README
- [ ] Create CONTRIBUTING.md
