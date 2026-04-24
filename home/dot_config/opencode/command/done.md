---
description: Verify work is complete, run the test suite, and summarize what was accomplished
agent: forge-verifier
subtask: true
---

Verify the current work is complete and correct before declaring done.

Steps:
1. Detect project type and run the appropriate verification suite:
   - TypeScript: `npx tsc --noEmit` + `pnpm test`
   - Go: `go vet ./...` + `go test ./...`
   - Rust: `cargo clippy` + `cargo test`
   - Python: `python -m mypy .` + `python -m pytest`
2. Run `git diff main...HEAD` — confirm scope matches what was asked
3. Check for leftover: TODO/FIXME/console.log/debug prints in changed files

Output:

```
## Verification Report

### Type Check: PASS / FAIL
[output excerpt if failed]

### Tests: PASS / FAIL — X passed, Y failed
[failing test names if any]

### Build: PASS / FAIL
[output excerpt if failed]

### Diff Scope
[summary of what changed — is it scoped correctly?]

### Leftovers
[any debug code, TODOs, or incomplete items found]

---
**VERDICT: VERIFIED ✓** — safe to ship
  or
**VERDICT: BLOCKED ✗** — [what must be fixed]
```

If $ARGUMENTS is provided, use it to focus verification (e.g., specific test files or directories).
