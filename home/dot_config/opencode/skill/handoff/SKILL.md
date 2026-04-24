---
name: handoff
description: Create a structured session handoff so another agent or future session can continue work without losing context or repeating investigation
---

# Handoff

A handoff is a complete transfer of working context. The reader should be able to continue immediately without asking clarifying questions.

## When to Write One

- Ending a session with work unfinished
- Handing a task to a subagent
- Switching between major workstreams

## Gather State First

```bash
git status
git log --oneline -10
git diff HEAD
git stash list
```

## Handoff Structure

```markdown
## Handoff: YYYY-MM-DD — [one-line description]

### Goal
What we were trying to accomplish. The actual goal, not a description of the tasks.

### Current State
- What is DONE and verified working
- What is partially done (and what specifically is incomplete)
- What is currently BROKEN (be explicit)

### Active Task
The specific thing being worked on right now, down to the function or line level.
Not "implementing auth" but "adding the refresh token rotation in `auth/session.ts:renewSession()`".

### Blockers
- [Unresolved question + where to find the answer]
- [Waiting on external thing]
- [Known issue that needs investigation first]

### Next Steps
1. [First action to take — specific command or edit]
2. [Second action]
3. [Continue...]

### Key Context
- Decisions made and why (especially non-obvious ones)
- Things tried that didn't work (save the next session from repeating)
- Where the relevant code lives

### Key Files
- `src/auth/session.ts` — active work happening here
- `src/auth/types.ts` — type definitions being modified

### Verify State With
\`\`\`bash
[command to confirm current state is what the handoff claims]
\`\`\`
```

## Quality Check

A good handoff passes this test: give it to someone who wasn't in the session and they can start working in under 5 minutes without asking questions.

Bad: "Working on the auth stuff, almost done"
Good: "Implementing refresh token rotation. `renewSession()` in `auth/session.ts` is written but the token storage call on line 87 is failing because `TokenStore.save()` expects a `TokenRecord` but we're passing a raw string. Next step: wrap the token in a `TokenRecord` object — see `auth/types.ts:TokenRecord` for the shape."
