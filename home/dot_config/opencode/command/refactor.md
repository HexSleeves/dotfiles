---
description: Analyze code and produce a sequenced refactoring plan with risk assessment
agent: refactor-planner
subtask: true
---

Produce a refactoring plan for $ARGUMENTS (file, module, or describe the problem). If no arguments, analyze the current diff for refactoring opportunities.

Process:
1. **Map current state** — Read the target code, understand coupling, duplication, naming issues
2. **Identify target state** — What does "done" look like? What invariants must be preserved?
3. **Sequence the steps** — Every step must leave the codebase working. No big-bang changes.
4. **Assess risk** — For each step: what could go wrong, how to detect it, how to roll back

Output format:
```
## Refactoring Plan: [scope]

### Problem
[what's wrong and why it matters]

### Target State
[what it should look like when done]

### Steps

#### Step 1: [name] — Risk: LOW
- What: [specific change]
- Files: [list with line ranges]
- Verify: [how to confirm correctness]
- Rollback: [how to undo]

#### Step 2: ...

### Invariants to Preserve
- [things that must not change externally]

### Tests to Add Before Starting
- [missing tests that would catch regressions]
```

Do not implement any changes. Plan only.
Each step should be small enough to review in a single PR.
