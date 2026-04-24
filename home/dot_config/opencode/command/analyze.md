---
description: Deep analysis of code, architecture, or a specific problem — research before acting
agent: forge-researcher
subtask: true
---

Perform a deep analysis of $ARGUMENTS. If no arguments, analyze the current project context and recent changes.

Analysis scope (adapt to what's provided):

**For a file or module:**
- What does it do? What are its dependencies and dependents?
- What patterns does it use? Are they consistent with the rest of the codebase?
- What are the edge cases and failure modes?
- What would a new developer need to understand to safely modify this?

**For a feature or system:**
- Trace the execution path end-to-end
- Map data flow: where does data enter, transform, and exit?
- Identify coupling points and abstraction boundaries
- Surface hidden dependencies and implicit contracts

**For a problem or question:**
- Gather evidence from the codebase (don't guess)
- Form a hypothesis, then verify it
- Return the answer with the evidence that supports it

Output:
```
## Analysis: [subject]

### Summary
[2-3 sentence answer to the core question]

### Key Findings
- `path/file.ts:line` — [finding]
- `path/file.ts:line` — [finding]

### Architecture / Data Flow
[prose or ASCII diagram as appropriate]

### Risks & Edge Cases
[non-obvious failure modes or coupling concerns]

### Recommendation
[what this analysis means for the task at hand — the actionable insight]
```

Read first. Do not modify any files.
