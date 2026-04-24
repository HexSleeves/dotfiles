---
description: Write a structured session handoff so work can be picked up without context loss
agent: build
---

Create a handoff document for the current session. Run these commands to gather state:

!`git status`
!`git log --oneline -10`
!`git diff HEAD`

Then write a handoff with this structure:

---
## Handoff: [date] — [one-line description of what was being worked on]

### Goal
[What we were trying to accomplish]

### Current State
[What is done, what is working, what is broken right now]

### What's In Progress
[Specific task being worked on at time of handoff — be precise about the step]

### Blockers
[Anything blocking progress, unresolved questions, waiting on external things]

### Next Steps
1. [First thing to do when picking this up]
2. [Second thing]
3. [Continue from here...]

### Key Files
- `path/file.ts` — [why it's relevant]

### Commands to Run First
```bash
# Verify current state
[command]
```

### Context / Decisions Made
- [Any non-obvious decisions made and why]
- [Things tried that didn't work]
---

If $ARGUMENTS is provided, treat it as the destination (file path to write the handoff to).
Otherwise print to the chat.
