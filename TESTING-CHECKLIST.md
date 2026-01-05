# Testing Checklist

Comprehensive testing guide for agent tooling setup.

## Pre-Release Testing

### Platform Compatibility

- [ ] **Linux (Ubuntu 22.04)**
  - [ ] Per-project installation
  - [ ] Global installation
  - [ ] Migration (local → global)
  - [ ] Migration (global → local)

- [ ] **macOS (latest)**
  - [ ] Per-project installation
  - [ ] Global installation
  - [ ] Migration (local → global)
  - [ ] Migration (global → local)

- [ ] **Windows WSL2**
  - [ ] Per-project installation
  - [ ] Global installation
  - [ ] Migration (local → global)
  - [ ] Migration (global → local)

- [ ] **Windows Native (limited support)**
  - [ ] Diagnostic script runs
  - [ ] Python tools install (empirica)
  - [ ] Proper error messages for unsupported tools

### Python Version Testing

- [ ] Python 3.10
- [ ] Python 3.11
- [ ] Python 3.12
- [ ] Python 3.13 (compatibility check)

### Installation Methods

#### Per-Project Mode

- [ ] **One-line install**
  ```bash
  curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install.sh | bash
  ```

- [ ] **Manual install**
  ```bash
  git clone https://github.com/jesposito/agent-tooling-setup.git
  cd agent-tooling-setup
  ./install.sh
  ```

- [ ] **With agent instructions**
  ```bash
  ./install.sh --with-agent-instructions
  ```

- [ ] **Skip install mode (config only)**
  ```bash
  ./install.sh --skip-install
  ```

#### Global Mode

- [ ] **One-line install**
  ```bash
  curl -fsSL https://raw.githubusercontent.com/jesposito/agent-tooling-setup/main/install-global.sh | bash
  ```

- [ ] **Manual install**
  ```bash
  git clone https://github.com/jesposito/agent-tooling-setup.git
  cd agent-tooling-setup
  ./install-global.sh
  ```

- [ ] **Project initialization**
  ```bash
  agent-tools init
  ```

### Core Tools Installation

- [ ] **Beads (bd)**
  - [ ] Install via brew (macOS)
  - [ ] Install via Go (cross-platform)
  - [ ] Install via npm fallback
  - [ ] `bd version` works
  - [ ] `bd init` works
  - [ ] `bd ready` works
  - [ ] `bd create` works
  - [ ] `bd sync` works

- [ ] **Perles**
  - [ ] Install via brew (macOS)
  - [ ] Install via Go fallback
  - [ ] `perles --version` works
  - [ ] `perles` launches UI
  - [ ] Kanban view works
  - [ ] Search view works (Ctrl+Space)
  - [ ] BQL queries work

- [ ] **Empirica**
  - [ ] Install from GitHub
  - [ ] `empirica --version` works
  - [ ] `empirica session-create` works
  - [ ] `empirica preflight-submit` works
  - [ ] `empirica postflight-submit` works

### Optional AI Tools

Test with `.agent-tools.yaml` configuration:

- [ ] **Mem0**
  - [ ] Base installation
  - [ ] With graph extras
  - [ ] With vector_stores extras
  - [ ] With llms extras
  - [ ] Import and basic usage

- [ ] **gptme**
  - [ ] Base installation
  - [ ] With browser extras (Playwright)
  - [ ] With datascience extras
  - [ ] With server extras
  - [ ] `gptme --version` works
  - [ ] Basic chat interaction

- [ ] **OpenCommit**
  - [ ] Install via npm
  - [ ] `oco config` works
  - [ ] `oco` generates commit message
  - [ ] Git hook installation (opt-in)
  - [ ] Multiple AI providers (OpenAI, Anthropic, Ollama)

- [ ] **Aider**
  - [ ] Base installation
  - [ ] With browser extras
  - [ ] `aider --version` works
  - [ ] Basic chat interaction
  - [ ] Auto-commit disabled by default
  - [ ] Safety prompts work

- [ ] **CodeRabbit CLI**
  - [ ] Installation (if privacy acknowledged)
  - [ ] `coderabbit --version` works
  - [ ] Pre-commit review

### Configuration System

- [ ] **Per-Project Mode**
  - [ ] `.agent-tools.yaml` created
  - [ ] YAML parsing works
  - [ ] Tool toggles work (enabled: true/false)
  - [ ] Tool-specific configs applied

- [ ] **Global Mode**
  - [ ] `~/.agent-tooling/config/.agent-tools.yaml` created
  - [ ] `.agent-tools.local.yaml` overrides work
  - [ ] Global config used when no local override
  - [ ] Per-project overrides merge correctly

### Diagnostics (`agent-tools-doctor.sh`)

- [ ] **Basic checks**
  - [ ] Python version detection
  - [ ] Git repository check
  - [ ] Tool installation checks
  - [ ] PATH configuration checks

- [ ] **Health scoring**
  - [ ] Score calculated (0-100%)
  - [ ] Issues reported
  - [ ] Suggestions provided

- [ ] **Platform-specific**
  - [ ] Python/python3 detection (Windows)
  - [ ] Version parsing works on all platforms
  - [ ] Numeric validation prevents errors

- [ ] **Reporting**
  - [ ] `--report` generates report
  - [ ] `--check-python` works
  - [ ] `--check-tools` works

### Updates (`agent-tools-update.sh`)

- [ ] **Pre-update checks**
  - [ ] Health check runs
  - [ ] Backup created
  - [ ] Timestamp in backup name

- [ ] **Update methods**
  - [ ] Brew update (macOS)
  - [ ] Go get update
  - [ ] pip update
  - [ ] npm update
  - [ ] Fallback methods work

- [ ] **Post-update validation**
  - [ ] Tools still work
  - [ ] Versions updated
  - [ ] Health check passes

- [ ] **Rollback**
  - [ ] Rollback offered on failure
  - [ ] Backup restoration works
  - [ ] Last 5 backups kept

- [ ] **Options**
  - [ ] `--dry-run` shows plan
  - [ ] `--tool <name>` updates specific tool
  - [ ] `--all` updates everything

### Migration (`migrate-mode.sh`)

- [ ] **Detection**
  - [ ] Detects "none" (no installation)
  - [ ] Detects "local" (per-project)
  - [ ] Detects "global" mode
  - [ ] Detects "mixed" (incomplete migration)

- [ ] **Local → Global**
  - [ ] Backup created
  - [ ] `.agent-tools.yaml` → `.agent-tools.local.yaml`
  - [ ] Local tools removed
  - [ ] Project registered in `~/.agent-tooling/projects/`
  - [ ] `.agent-tools.global-init` marker created
  - [ ] `.gitignore` updated
  - [ ] `.beads/` preserved
  - [ ] `.claude/` preserved
  - [ ] `AGENTS.md` preserved

- [ ] **Global → Local**
  - [ ] Backup created
  - [ ] `.agent-tools.local.yaml` → `.agent-tools.yaml`
  - [ ] Tools installed locally
  - [ ] Project unregistered from global
  - [ ] Markers removed
  - [ ] `.gitignore` updated

- [ ] **Options**
  - [ ] `--dry-run` shows plan
  - [ ] `--backup` creates backup
  - [ ] `--no-backup` skips backup
  - [ ] Refuses to run in mixed state without backup

### Git Integration

- [ ] **Gitignore**
  - [ ] Auto-managed section added
  - [ ] Sensitive files ignored (.env, API keys)
  - [ ] Cache directories ignored
  - [ ] Installation artifacts ignored
  - [ ] Mode-specific entries correct

- [ ] **Beads Integration**
  - [ ] `.gitattributes` created
  - [ ] Merge strategy for `.beads/` set
  - [ ] `bd sync` works
  - [ ] Git commits include .beads updates

### Workflow Integration

- [ ] **Session Workflow**
  ```bash
  empirica session-create --ai-id test
  bd create "Test task" --priority P1
  bd ready  # Shows task
  bd update <id> --status in_progress
  perles  # Shows in kanban
  bd close <id>
  bd sync
  git push
  ```

- [ ] **Claude Code Integration**
  - [ ] Can read `docs/DEVELOPMENT.md`
  - [ ] Can read `AGENTS.md`
  - [ ] Can read `agent-instructions.md` (if created)
  - [ ] Instructions work as expected

### Security & Safety

- [ ] **API Key Management**
  - [ ] `.env` template created
  - [ ] `.env` in gitignore
  - [ ] Keys not leaked to git
  - [ ] Keys loaded correctly by tools

- [ ] **Auto-commit Safety**
  - [ ] Aider auto-commit disabled by default
  - [ ] OpenCommit git hook opt-in only
  - [ ] Confirmations required for dangerous operations

- [ ] **External Service Privacy**
  - [ ] CodeRabbit CLI requires privacy acknowledgment
  - [ ] Warning shown for external services

### Documentation

- [ ] **README.md**
  - [ ] Accurate installation instructions
  - [ ] Both modes documented
  - [ ] Links work
  - [ ] Examples correct

- [ ] **QUICKSTART.md**
  - [ ] Quick start works end-to-end
  - [ ] Commands accurate
  - [ ] Examples work

- [ ] **INSTALLATION-MODES.md**
  - [ ] Comparison table accurate
  - [ ] Migration instructions work
  - [ ] FAQ answers common questions

- [ ] **WINDOWS-NOTES.md**
  - [ ] Compatibility matrix accurate
  - [ ] Workarounds documented
  - [ ] WSL recommendation clear

- [ ] **ANALYSIS.md**
  - [ ] Tool analysis accurate
  - [ ] Edge cases documented
  - [ ] Recommendations sound

- [ ] **ENHANCEMENTS-SUMMARY.md**
  - [ ] Features documented
  - [ ] Examples work
  - [ ] Benefits clear

### Error Handling

- [ ] **Installation Errors**
  - [ ] Missing git repo detected
  - [ ] Python version too old detected
  - [ ] Network errors handled gracefully
  - [ ] Partial install handled

- [ ] **Runtime Errors**
  - [ ] Missing tools detected
  - [ ] PATH issues diagnosed
  - [ ] Configuration errors reported
  - [ ] Helpful error messages

### Edge Cases

- [ ] **Concurrent Operations**
  - [ ] Multiple tools don't conflict
  - [ ] Git operations serialized
  - [ ] File locks handled

- [ ] **Large Codebases**
  - [ ] Installation works on large repos
  - [ ] Beads handles many issues
  - [ ] Performance acceptable

- [ ] **Network Issues**
  - [ ] Installation retries
  - [ ] Timeouts handled
  - [ ] Offline mode works (skip optional)

- [ ] **Disk Space**
  - [ ] Low disk space detected
  - [ ] Cache cleanup offered
  - [ ] Backup rotation works

## Continuous Integration

### GitHub Actions

- [ ] **Test workflow**
  - [ ] Runs on push
  - [ ] Runs on PR
  - [ ] Tests on Ubuntu
  - [ ] Tests on macOS
  - [ ] Tests on Windows (if supported)

- [ ] **Matrix testing**
  - [ ] Multiple Python versions
  - [ ] Multiple platforms
  - [ ] Both installation modes

## Manual Testing Scenarios

### Scenario 1: New User, Per-Project

1. [ ] Clone test repo
2. [ ] Run one-line install
3. [ ] Create first task with `bd create`
4. [ ] Start session with `empirica session-create`
5. [ ] View board with `perles`
6. [ ] Complete workflow from QUICKSTART.md
7. [ ] Run diagnostic: `./agent-tools-doctor.sh`

### Scenario 2: New User, Global Mode

1. [ ] Run global install
2. [ ] Verify `agent-tools` in PATH
3. [ ] `cd` to test repo
4. [ ] Run `agent-tools init`
5. [ ] Complete workflow from QUICKSTART.md
6. [ ] `cd` to second repo
7. [ ] Run `agent-tools init`
8. [ ] Verify shared tools work

### Scenario 3: Migration

1. [ ] Start with per-project install
2. [ ] Work on project (create tasks, etc.)
3. [ ] Run `./migrate-mode.sh to-global --dry-run`
4. [ ] Review dry-run output
5. [ ] Run `./migrate-mode.sh to-global`
6. [ ] Verify migration successful
7. [ ] Verify existing work preserved
8. [ ] Run health check

### Scenario 4: Team Workflow

1. [ ] Developer A initializes repo
2. [ ] Developer A commits `.beads/`, `AGENTS.md`, `.claude/`
3. [ ] Developer A pushes to remote
4. [ ] Developer B clones repo
5. [ ] Developer B runs install (same mode)
6. [ ] Developer B sees existing tasks
7. [ ] Both developers create tasks
8. [ ] Both developers sync (`bd sync`)
9. [ ] Verify no conflicts

### Scenario 5: Update Workflow

1. [ ] Install tools (old version if possible)
2. [ ] Verify tools work
3. [ ] Run `./agent-tools-update.sh --dry-run`
4. [ ] Run `./agent-tools-update.sh`
5. [ ] Verify updates applied
6. [ ] Verify tools still work
7. [ ] Check backup created
8. [ ] Verify old backups cleaned

### Scenario 6: Windows User

1. [ ] Clone repo on Windows
2. [ ] Run diagnostic script
3. [ ] Verify Python detection works
4. [ ] Verify helpful error messages
5. [ ] Install WSL (if testing WSL mode)
6. [ ] Repeat in WSL
7. [ ] Verify tools work in WSL

## Performance Testing

- [ ] **Large repositories (100k+ LOC)**
  - [ ] Installation completes in reasonable time
  - [ ] Tools remain responsive
  - [ ] Memory usage acceptable

- [ ] **Many tasks (1000+ beads)**
  - [ ] `bd ready` fast
  - [ ] `perles` responsive
  - [ ] Git operations reasonable

- [ ] **Slow networks**
  - [ ] Installation works
  - [ ] Reasonable timeouts
  - [ ] Retries work

## Regression Testing

After any changes, verify:

- [ ] Previous installations still work
- [ ] Migration still works
- [ ] No breaking changes to config format
- [ ] Existing projects unaffected

## Release Checklist

Before releasing a new version:

- [ ] All tests pass
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Version numbers bumped
- [ ] GitHub release created
- [ ] Installation scripts tested from raw.githubusercontent.com
- [ ] Announcement prepared

## Bug Report Template

When filing issues, include:

- Platform (OS, version)
- Python version
- Installation mode (global/per-project)
- Full error output
- Steps to reproduce
- `agent-tools-doctor.sh` output

## Notes

- Tests marked with ⚠️  require manual verification
- Tests marked with 💰 require API keys
- Tests marked with 🌐 require network access
- Tests marked with 🔒 test security features
