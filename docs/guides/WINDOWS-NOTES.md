# Windows Compatibility Notes

## Current Status

The agent-tooling-setup is primarily designed for **Linux and macOS**. Most core tools have limited or no native Windows support.

## Tool Compatibility Matrix

| Tool | Windows (Native) | Windows (WSL) | Linux | macOS |
|------|------------------|---------------|-------|-------|
| **Beads (bd)** | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes |
| **Empirica** | ⚠️ Untested | ✅ Yes | ✅ Yes | ✅ Yes |
| **Perles** | ❌ No | ✅ Yes | ✅ Yes | ✅ Yes |
| **OpenCommit** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **gptme** | ⚠️ Limited | ✅ Yes | ✅ Yes | ✅ Yes |
| **Aider** | ⚠️ Limited | ✅ Yes | ✅ Yes | ✅ Yes |
| **Mem0** | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| **CodeRabbit CLI** | ⚠️ WSL only | ✅ Yes | ✅ Yes | ✅ Yes |

## Recommended Setup for Windows Users

### Option 1: WSL 2 (Recommended)

Install Windows Subsystem for Linux 2:

```powershell
# In PowerShell (Administrator)
wsl --install
```

Then run the installer in WSL:

```bash
# In WSL terminal
cd /mnt/c/Users/YourName/your-project
curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash
```

**Pros:**
- ✅ Full compatibility with all tools
- ✅ Native Linux environment
- ✅ Can access Windows files

**Cons:**
- ⚠️ Requires WSL 2 installation
- ⚠️ Some performance overhead

### Option 2: Partial Install (Native Windows)

Install only Windows-compatible tools:

```powershell
# Install Node.js (for OpenCommit)
# Download from: https://nodejs.org/

# Install Python (for Mem0, possibly Empirica)
# Download from: https://python.org/

# Install OpenCommit
npm install -g opencommit

# Install Mem0
pip install mem0ai

# Configure
oco config set OCO_API_KEY=your-key-here
```

**Pros:**
- ✅ No WSL required
- ✅ Faster for simple use cases

**Cons:**
- ❌ No Beads (task tracking)
- ❌ No Perles (kanban board)
- ⚠️ Limited workflow

### Option 3: Git Bash / MinGW

Some tools may work in Git Bash or MinGW:

```bash
# Install Git for Windows (includes Git Bash)
# Download from: https://git-scm.com/

# Try installing in Git Bash
./install.sh --skip-install  # Config only
```

**Pros:**
- ✅ No WSL needed
- ✅ Bash-like environment

**Cons:**
- ⚠️ Limited tool support
- ⚠️ Path compatibility issues

## Tool-Specific Notes

### Beads (bd)
- **Status:** Linux/macOS only (Go binary)
- **Windows:** Use WSL or wait for Windows release
- **Workaround:** Manual .beads/ directory (limited)

### Empirica
- **Status:** Python package, should work on Windows
- **Windows:** Install via `pip install git+https://github.com/Nubaeon/empirica.git`
- **Issues:** May have path compatibility issues

### Perles
- **Status:** Terminal UI, Linux/macOS only
- **Windows:** Use WSL
- **Workaround:** None (requires ncurses)

### OpenCommit
- **Status:** ✅ Full Windows support (Node.js)
- **Windows:** `npm install -g opencommit`
- **Works perfectly on native Windows**

### gptme
- **Status:** ⚠️ Limited Windows support
- **Windows:** Install with `pipx install gptme`
- **Issues:** Some tools (browser, computer) may not work

### Aider
- **Status:** ⚠️ Limited Windows support
- **Windows:** Install with `pip install aider-chat`
- **Issues:** Git integration may have quirks

### Mem0
- **Status:** ✅ Full Windows support (Python)
- **Windows:** `pip install mem0ai`
- **Works perfectly on native Windows**

### CodeRabbit CLI
- **Status:** WSL only (officially)
- **Windows:** Install in WSL
- **Alternative:** Use web interface

## Diagnostic Script on Windows

The `agent-tools-doctor.sh` has been updated to handle Windows:

- ✅ Detects `python` vs `python3`
- ✅ Handles Windows paths
- ✅ Reports Windows-specific limitations

Run with Git Bash:

```bash
./agent-tools-doctor.sh
```

## Development Notes

This project was developed on Windows and tested in Git Bash. The installation scripts and tools are designed for Unix-like environments but include Windows compatibility where possible.

### Known Issues on Windows

1. **Line Endings:** Git may convert LF to CRLF
   - Solution: `git config core.autocrlf false`

2. **Path Separators:** Some tools expect Unix paths
   - Solution: Use WSL for full compatibility

3. **Shell Scripts:** Require bash interpreter
   - Solution: Use Git Bash or WSL

4. **Binary Tools:** Go and Rust binaries are platform-specific
   - Solution: Use WSL or wait for Windows builds

## Recommendations by Use Case

### Use Case: Full AI Agent Development
**Recommendation:** WSL 2
**Why:** Need all tools (Beads, Perles, Empirica)

### Use Case: Just AI Commit Messages
**Recommendation:** Native Windows
**Why:** OpenCommit works perfectly on Windows

### Use Case: Python AI Development
**Recommendation:** Native Windows or WSL
**Why:** Python tools (Mem0, possibly gptme/Aider) work on both

### Use Case: Team Collaboration
**Recommendation:** WSL 2 or Linux/macOS
**Why:** Beads (task tracking) is essential

## Future Improvements

### Planned
- [ ] Test all Python tools on native Windows
- [ ] Document exact compatibility for each tool
- [ ] Create Windows-specific install script
- [ ] Build Windows binaries for Beads (if possible)

### Community Contributions Welcome
- Windows testing and bug reports
- Windows-specific documentation
- PowerShell install script
- Native Windows tool alternatives

## Getting Help

- **WSL Installation:** https://learn.microsoft.com/en-us/windows/wsl/install
- **Git Bash:** https://git-scm.com/download/win
- **Python on Windows:** https://docs.python.org/3/using/windows.html
- **Node.js on Windows:** https://nodejs.org/en/download/

## Summary

**For best experience on Windows:**
1. Install WSL 2
2. Run installer in WSL
3. Access Windows files via `/mnt/c/`

**For quick start (limited functionality):**
1. Install Node.js and Python
2. Install OpenCommit and Mem0
3. Use for AI commit messages and memory

---

**Note:** This is an evolving document. Windows support is improving. Check back for updates!
