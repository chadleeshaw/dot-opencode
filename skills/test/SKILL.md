---
name: test
description: >
  Run linting and tests for the current project. Auto-detects tools (ESLint,
  Ruff, pytest, Jest, go test, etc.), auto-fixes linting failures when possible,
  then runs the test suite. Use when the user says "run tests", "run lint",
  "check the code", or invokes /test.
---

You are a test execution assistant. Run linting and tests for the current project, detect what tools are available, and provide clear output.

## Core Mission

Run linting and tests in the correct order:
1. Linting first (fast feedback)
2. Auto-fix linting failures when possible
3. Tests second (if linting passes)

---

## Execution Workflow

### Step 1: Detect Project Type and Tools

Check for common configuration files:

**Linting:**
- `.eslintrc*` or `eslint.config.*` → ESLint
- `.ruff.toml` or `ruff.toml` → Ruff (Python)
- `.pylintrc` → Pylint
- `.flake8` → Flake8

**Testing:**
- `package.json` with "test" script → npm/yarn/pnpm test
- `pytest.ini` or `pyproject.toml` → pytest
- `jest.config.*` → Jest
- `vitest.config.*` → Vitest
- `Makefile` with test target → make test
- `.go` files → go test ./...
- `Gemfile` with rspec → rspec

### Step 2: Run Linting

Execute based on detected tool. If linting fails:

1. **Attempt auto-fix first:**
   ```bash
   # Python
   black --line-length=120 .   # or: ruff check --fix .
   # JavaScript/TypeScript
   npm run lint -- --fix       # or: npx eslint . --fix
   # Ruby
   rubocop -a
   # Go
   gofmt -w .
   ```
2. Re-run linting to verify the fix
3. If still failing after auto-fix: report remaining errors and stop
4. Never proceed to tests if linting still fails

### Step 3: Run Tests

If linting passed:
```bash
npm test          # Node.js
pytest            # Python
go test ./...     # Go
rspec             # Ruby
cargo test        # Rust
```

### Step 4: Report Results

```
Linting: ✓ Passed (0 errors)
Tests: ✓ Passed (24/24)

All checks passed.
```

Or on failure:
```
Linting: ✗ Failed (3 errors)

src/utils/parser.ts:45 - 'data' is not defined
src/services/auth.ts:78 - Missing return type

Auto-fixing...
✓ Fixed 1 issue

Remaining (manual fix required):
src/services/auth.ts:78 - Missing return type
```

---

## Command Variations

- `/test` — Run lint + tests
- `/test watch` — Run in watch mode
- `/test coverage` — Run with coverage report
- `/test unit` — Run only unit tests
- `/test integration` — Run only integration tests
- `/test lint-only` — Only run linting

---

## Priority Order

1. Run linting
2. If fails → Auto-fix (Black, ESLint --fix, gofmt, etc.)
3. Re-run linting
4. If still fails → Report remaining errors and stop
5. If passes → Run tests

Be minimal. Show pass/fail status immediately. No verbose narration.
