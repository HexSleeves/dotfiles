---
name: pr-review
description: Comprehensive PR review methodology covering correctness, security, tests, and style — use when asked to review a pull request or branch diff
---

# PR Review

## Gather the Diff

```bash
# For a GitHub PR
gh pr diff <number>

# For a local branch vs main
git diff main...HEAD

# Get changed file list
git diff --name-only main...HEAD
```

## Review Order

Work in this order — stop and flag critical issues before reviewing style.

### 1. Understand Intent
Read the PR description (or `git log --oneline main...HEAD`). Know what the PR *should* do before reading what it *does*.

### 2. Correctness Pass
For each changed file:
- Read the full file, not just the diff — context matters
- Trace the happy path: does the logic match the intent?
- Trace error paths: what happens when things fail?
- Check boundary conditions: empty input, max values, concurrent access

### 3. Security Pass
- Input validation at all entry points (HTTP, files, env vars, CLI args)
- Auth/authz: are all new routes/handlers protected?
- Data exposure: does any new code log or return sensitive data?
- Dependency changes: any new packages with known CVEs?

### 4. Test Pass
- Is new behavior covered by tests?
- Are tests testing behavior or implementation? (behavior preferred)
- Are failure cases tested, not just the happy path?
- Run the tests if you can: `pnpm test` / `go test ./...` / `cargo test`

### 5. Style & Maintainability
- Names communicate intent without comments
- No unnecessary complexity (clever < clear)
- No dead code, commented-out blocks, or leftover debugging

## Severity Levels

| Level | Meaning | Action |
|---|---|---|
| **CRITICAL** | Security vulnerability, data loss, crash | Block merge |
| **HIGH** | Correctness bug, missing error handling | Block merge |
| **MEDIUM** | Code quality, test gap, non-obvious behavior | Should fix |
| **LOW** | Style, naming, minor improvement | Optional |

## Output Template

```
## PR Review: [title or PR#]

### Critical
- `file.ts:42` — [specific problem + why it's critical]

### High
- `file.ts:87` — [problem]

### Medium  
- `file.ts:112` — [problem]

### Low
- `file.ts:130` — [suggestion]

### Positive Notes
- [what was done well — be specific]

### Verdict
[APPROVE | REQUEST CHANGES] — [1-2 sentence summary]
```

## When Reviewing Agent-Generated Code

Look specifically for:
- Comments that describe what the code does (not why) — likely AI filler
- Overly defensive null-checks for values that can't be null
- Unused variables prefixed with `_` added for "backwards compatibility"
- Unnecessary abstraction layers wrapping single-use functions
- Generic error messages that don't surface enough context
