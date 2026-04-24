---
description: Review code changes for bugs, security issues, and style violations
agent: reviewer
subtask: true
---

Perform a thorough code review. Focus on recently changed code.

Steps:
1. Run `git diff main...HEAD` (or `git diff HEAD` if no PR) to get the diff
2. For each changed file, read the full file for context — not just the diff
3. Review for:
   - **Correctness**: Logic errors, off-by-one, null/undefined dereferences
   - **Security**: Input validation, auth bypass, injection vectors, sensitive data exposure
   - **Error handling**: Swallowed exceptions, missing error propagation
   - **Types**: Unsound casts, missing narrowing, `any` escape hatches
   - **Performance**: N+1 queries, unnecessary re-renders, blocking operations
   - **Tests**: Missing coverage for new branches, edge cases untested

If $ARGUMENTS is provided, focus the review on those files or concerns.

Output format:
```
## Review: [scope]

### Critical (must fix)
- `file.ts:42` — [what and why]

### High (should fix)
- `file.ts:87` — [what and why]

### Low (consider)
- `file.ts:112` — [what and why]

### Summary
[2-3 sentence verdict and recommended action]
```

Do not apply any changes. Report only.
