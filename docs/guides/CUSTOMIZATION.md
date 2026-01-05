# Customization Guide

The `agent-instructions.md` template is designed to be customized for your specific project. Here's how to adapt it:

## Quick Start

1. **Copy to your project**: The installer creates this file with `--with-agent-instructions`
2. **Search for [CUSTOMIZE]**: Each section marked with `[CUSTOMIZE]` needs your attention
3. **Fill in project details**: Replace example content with your project's specifics
4. **Remove the comment block**: Delete the customization guide comment at the top

## What to Customize

### Section 0: Agent-Specific Operating Rules

This section includes **Professional Communication Standards** by default - these ensure agents write professional commit messages, PRs, and documentation without signatures or casual language.

**You may want to adjust these standards based on your team's preferences:**

```markdown
<!-- More strict: Add specific format requirements -->
**Commit Message Format:**
- Must follow conventional commits (feat:, fix:, docs:, etc.)
- Must reference issue number
- Body must explain WHY not WHAT

**PR Description Template:**
Must include:
- Summary of changes
- Testing performed
- Breaking changes (if any)
- Screenshots (for UI changes)
```

```markdown
<!-- More relaxed: Allow some personality -->
**Communication Standards:**
- Professional tone in commits and PRs
- Emojis allowed in PR descriptions only
- Informal tone acceptable in code comments for clarity
```

**Add your project's technical guardrails:**

```markdown
<!-- Example for a Django project -->
- If you touch models, read `docs/DATABASE.md` and create migrations
- Authentication changes require security review in `docs/SECURITY.md`
- Never commit migrations without running tests
```

```markdown
<!-- Example for a React app -->
- All API calls must use the `apiClient` wrapper
- State updates require Redux actions, never direct mutations
- Component changes need Storybook stories
```

### Section 1: Your Role

**Adjust roles to match your team structure:**

- Solo developer? You might remove UX Designer
- Backend API? You might emphasize Software Architect
- Startup? You might add "Growth Hacker" role

### Section 2: Orientation Step

**List YOUR documentation files:**

```markdown
2. Review existing documentation:
   - `README.md` - Project overview
   - `docs/API.md` - API endpoints and contracts
   - `docs/DEPLOYMENT.md` - Deployment procedures
   - `docs/CHANGELOG.md` - Recent changes
```

### Section 4: Discovery & Design First

**Add project-specific design requirements:**

```markdown
<!-- For API projects -->
- All API changes require OpenAPI spec updates
- Breaking changes need migration guide

<!-- For UI projects -->
- UI changes need Figma mockups or wireframes
- Accessibility requirements must be documented
```

### Section 5: Implementation Standards

**Add your coding standards:**

```markdown
<!-- TypeScript project -->
- Use TypeScript strict mode
- Prefer functional components with hooks
- Use Zod for runtime validation

<!-- Python project -->
- Follow PEP 8 and use Black for formatting
- Type hints required for all functions
- Use pytest for all tests

<!-- Go project -->
- Follow Effective Go guidelines
- Use golangci-lint with project config
- Error wrapping required with %w
```

### Section 7: Testing & Verification

**Add your test commands:**

```markdown
### Required Commands

```bash
npm run test          # Unit tests
npm run test:e2e      # End-to-end tests
npm run lint          # Linting
npm run type-check    # TypeScript
```

**Coverage requirement: 80% minimum**
```

### Section 8: Environment & Tooling

**Document your setup:**

```markdown
### Required Tools
- Node.js 18+
- PostgreSQL 14+
- Redis 7+

### Development Commands
```bash
make dev              # Start dev environment
make db:migrate       # Run migrations
make test             # Run all tests
make docker:up        # Start dependencies
```
```

### Section 10: Project-Specific Guidelines

**This is where you add everything unique to your project:**

```markdown
## Project-Specific Guidelines

### Branch Naming
- feature/description
- bugfix/description
- hotfix/description

### Commit Messages
Follow conventional commits:
- feat: new feature
- fix: bug fix
- docs: documentation
- refactor: code refactoring

### PR Process
1. Create feature branch
2. Implement with tests
3. Update docs/CHANGELOG.md
4. Submit PR with template
5. Require 1 approval minimum

### Deployment
- Staging: Auto-deploy from `develop` branch
- Production: Manual deploy from `main` branch
- Migrations run automatically via Kubernetes init containers
```

## Real-World Examples

### Example 1: Full-Stack Web App

```markdown
## 0. Agent-Specific Operating Rules

**Project guardrails:**
- Database changes require migrations (never modify schema directly)
- API changes need OpenAPI spec updates in `docs/api.yml`
- UI changes require Storybook stories and accessibility checks
- Authentication code changes require security review

## Section 10: Project-Specific Guidelines

### Stack
- Frontend: React + TypeScript + TailwindCSS
- Backend: Node.js + Express + Prisma
- Database: PostgreSQL
- Auth: Auth0

### File Organization
```
src/
  client/
    components/   # Reusable UI components
    pages/        # Page components
    hooks/        # Custom hooks
  server/
    routes/       # API routes
    services/     # Business logic
    middleware/   # Express middleware
  shared/
    types/        # Shared TypeScript types
```

### Naming Conventions
- Components: PascalCase (`UserProfile.tsx`)
- Utilities: camelCase (`formatDate.ts`)
- Constants: UPPER_SNAKE_CASE (`API_BASE_URL`)
- Database tables: snake_case (`user_profiles`)

### API Standards
- RESTful endpoints
- JSON responses always include `{ success, data, error }`
- Use HTTP status codes correctly
- Rate limiting: 100 req/min per IP

### Testing Requirements
- Unit tests for all services
- Integration tests for API endpoints
- E2E tests for critical user flows
- Minimum 80% coverage
```

### Example 2: Python Data Pipeline

```markdown
## 0. Agent-Specific Operating Rules

**Project guardrails:**
- All data transformations must be idempotent
- Schema changes require Alembic migrations
- Pipeline changes need data validation tests
- Performance changes require benchmarks

## Section 10: Project-Specific Guidelines

### Stack
- Python 3.11+
- Apache Airflow for orchestration
- Pandas + Polars for data processing
- PostgreSQL + Redis

### Code Standards
- PEP 8 via Black formatting
- Type hints on all functions
- Docstrings in Google style
- Use Pydantic for data validation

### Pipeline Patterns
```python
# All transform functions follow this pattern
def transform_data(
    input_df: pd.DataFrame,
    config: Config
) -> pd.DataFrame:
    """Transform data according to config.

    Args:
        input_df: Input dataframe
        config: Transformation config

    Returns:
        Transformed dataframe

    Raises:
        ValidationError: If data validation fails
    """
```

### Testing
```bash
pytest tests/           # All tests
pytest tests/unit/      # Unit tests only
pytest tests/integration/  # Integration tests
pytest --cov=src --cov-report=html  # With coverage
```

### Airflow DAGs
- DAG files in `dags/`
- Operators in `operators/`
- Sensors in `sensors/`
- Schedule: Use cron expressions, not intervals
```

### Example 3: Mobile App (React Native)

```markdown
## 0. Agent-Specific Operating Rules

**Project guardrails:**
- Navigation changes must preserve deep linking
- API calls require error handling and offline support
- New screens need loading and error states
- Platform-specific code needs iOS + Android testing

## Section 10: Project-Specific Guidelines

### Stack
- React Native + TypeScript
- React Navigation
- Redux Toolkit + RTK Query
- React Native Paper (UI)

### Platform Considerations
- Test on both iOS simulator and Android emulator
- Use Platform.select() for platform-specific code
- Respect safe areas on iOS
- Handle Android back button

### State Management
```typescript
// Redux slice pattern
export const userSlice = createSlice({
  name: 'user',
  initialState,
  reducers: { ... },
  extraReducers: (builder) => { ... }
});
```

### Component Structure
```
src/
  screens/        # Screen components
  components/     # Reusable components
  navigation/     # Navigation config
  store/          # Redux store and slices
  services/       # API and external services
  hooks/          # Custom hooks
  utils/          # Utility functions
  theme/          # Theme configuration
```

### Testing
- Jest for unit tests
- React Native Testing Library for components
- Detox for E2E tests (configured for iOS + Android)
```

## Tips for Good Customization

1. **Be Specific**: Don't just say "follow best practices" - say WHICH practices
2. **Add Commands**: Include actual commands devs/agents can run
3. **Link to Docs**: Reference your project's documentation
4. **Include Examples**: Show code snippets of the patterns you want
5. **Keep Updated**: Update this as your project evolves

## After Customization

1. Remove the `[CUSTOMIZE]` markers
2. Remove the comment block at the top
3. Commit to your repository
4. Reference in your `docs/DEVELOPMENT.md`
5. Share with your team

## Questions to Ask Yourself

- What breaks often in our project? → Add guardrails
- What do new devs get wrong? → Add to standards
- What's our review process? → Document it
- What tools do we use? → List commands
- What's our deployment process? → Document steps

---

**The goal**: Make it impossible for an AI agent (or human) to do the wrong thing by accident.
