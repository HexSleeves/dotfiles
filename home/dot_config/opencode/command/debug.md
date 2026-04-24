---
description: Diagnose a bug or test failure with root-cause analysis
agent: forge-debugger
subtask: true
---

Diagnose the issue described in $ARGUMENTS (or the most recent error/failure if no arguments given).

Protocol:
1. **Reproduce** — Run the failing test/command exactly. Confirm reproduction.
2. **Recent changes** — `git log --oneline -20` and `git diff HEAD~3` to see what changed
3. **Isolate** — What is the minimal failing case? What passes that shouldn't?
4. **Trace** — Follow the error backwards. The top frame is rarely the root cause.
5. **Hypothesize** — State explicitly: "X is failing because Y, evidence: Z"
6. **Verify** — Run a targeted test to confirm/deny the hypothesis

Output:
```
## Diagnosis

**Reproduced**: yes/no + exact command used

**Root cause**: `path/file.ts:line` — what's wrong and why

**Evidence**: [the specific log/trace/value that proves it]

**Proposed fix**: [minimal change — do not apply]

**Confidence**: high/medium/low
```

Never apply the fix. Diagnose only — hand off to the build agent to implement.
