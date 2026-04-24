---
description: Create a pull request with a structured title, summary, and test plan
agent: build
---

Create a pull request for the current branch. Follow these steps exactly:

1. Run `git status` and `git diff main...HEAD` to understand all changes
2. Run `git log main...HEAD --oneline` to see all commits in this branch
3. Analyze what changed — features, fixes, refactors — across ALL commits, not just the last
4. Run `gh pr create` with this structure:

**Title format**: `type: short description` (under 70 chars)
Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `perf`

**Body format**:
```
## Summary
- [bullet: what changed and why, 1–3 points]

## Changes
- [specific files/components changed]

## Test plan
- [ ] [how to verify this works]
- [ ] [edge cases tested]
- [ ] [regression check]
```

If $ARGUMENTS is provided, treat it as additional context about the PR purpose.

Rules:
- Never force-push to main/master
- Include the full diff scope — not just the last commit
- Use `gh pr create --title "..." --body "..."` with a heredoc for the body
