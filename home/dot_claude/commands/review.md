---
description: Review code changes with structured grading (A-F)
allowed-tools: Bash(git diff:*), Bash(git rev-parse:*), Bash(gh pr diff:*)
argument-hint: [--staged | --branch | --pr <url>]
---

Review code and provide a structured assessment with grading.

Arguments: $ARGUMENTS

## Diff Source Resolution

Determine the diff to review based on arguments:

| Argument | Diff command | Use case |
|----------|-------------|----------|
| (none) | `git diff` + `git diff --staged` | Review uncommitted + staged changes |
| `--staged` | `git diff --staged` | Review only staged changes |
| `--branch` | `git diff origin/<base>...HEAD` | Review branch diff vs base branch |
| `--pr <url>` | `gh pr diff <url>` | Review a GitHub PR |

### Step 1: Get the diff

Based on the arguments, run the appropriate diff command:

```bash
# Default (no args): uncommitted + staged
DIFF=$(git diff; git diff --staged)

# --staged: only staged
DIFF=$(git diff --staged)

# --branch: branch diff (detect base branch)
BASE=$(git rev-parse --abbrev-ref HEAD@{upstream} 2>/dev/null | sed 's|origin/||' || git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo "main")
DIFF=$(git diff origin/$BASE...HEAD)

# --pr <url>: PR diff
DIFF=$(gh pr diff <url>)
```

If the diff is empty, report "No changes to review" and stop.

### Step 2: Review the diff

Review the diff systematically. For each issue found, classify by severity:

**CRITICAL** - Must fix before merge:
- Security vulnerabilities (injection, auth bypass, secrets in code)
- Data loss risks (missing transactions, unsafe deletes)
- Correctness bugs (race conditions, nil dereference, logic errors)

**MAJOR** - Should fix before merge:
- Logic errors that may not crash but produce wrong results
- Missing error handling on external calls
- API contract violations
- Missing tests for critical paths

**MINOR** - Nice to fix:
- Style inconsistencies with surrounding code
- Naming issues (unclear or misleading names)
- Missing comments on non-obvious logic
- Minor code smells

For each issue, note:
- File and line number
- Severity (CRITICAL, MAJOR, MINOR)
- Description of the issue
- Suggested fix (specific, actionable)

### Step 3: Forced artifacts

Write these lines literally. They are gates, not commentary: writing one forces the check that
earns it, and each one you write appears verbatim in the Step 5 output. Only write a line the
diff actually owes — a gate that doesn't apply produces no line.

**`EVIDENCE`** — every issue you report must cite a `file:line` that appears in the diff or in a
file you opened while reviewing. An issue inferred from a pattern you expect to be there, without
opening the code, is not a finding. Drop it or go read the file.

**`INTENT`** — owed whenever the diff changes existing behavior (not for new files, pure
additions, or renames). Before reporting on that change, open the spec source and write:

```
INTENT: code now does <X>; tests expect <Y>; spec (<README/docstring/type/comment + path>) says <Z>
```

You must actually open the third slot's source to fill it. If X, Y, and Z do not all agree, the
disagreement *is* the finding — report it as CRITICAL or MAJOR, not as a style note. Authority
order when they conflict: an explicit user statement beats the spec, the spec beats the tests,
the tests beat current code behavior. "Make the tests pass" does not promote tests above the spec.

**`TWINS`** — owed once per CRITICAL and MAJOR issue. A defect in one place is presumed to recur
elsewhere until you have searched. Name the exact wrong construct, grep the repo for it, and write:

```
TWINS: searched <the pattern> — found <N> other sites: <files, or "none">
```

Report the other sites as their own issues at the same severity. A completeness claim with no
search behind it is a fabrication.

**Artifact gate**, last check before output: sweep the finished review once. Behavior changed and
no `INTENT:` line? Add it. A CRITICAL or MAJOR issue with no `TWINS:` line? Add it. An issue with
no `file:line`? Verify it or cut it. A clean review passes untouched.

### Step 4: Assign grade

Grade is determined by the highest severity issue found:

| Grade | Criteria | Verdict |
|-------|----------|---------|
| **A** | No CRITICAL, MAJOR, or MINOR issues | PASS |
| **B** | MINOR issues only (no CRITICAL or MAJOR) | PASS |
| **C** | MAJOR issues present (no CRITICAL) | FAIL |
| **D** | CRITICAL issues present | FAIL |
| **F** | Unreviewable (empty diff, binary files, generated code only) | SKIP |

### Step 5: Output structured review

Output the review in this exact format:

```
Grade: <A|B|C|D|F>

INTENT: code now does <X>; tests expect <Y>; spec (<source>) says <Z>

CRITICAL (<count> issues)
  <file>:<line> — <description>
    TWINS: searched <pattern> — found <N> other sites: <files, or "none">
    Suggested fix: <actionable fix>

MAJOR (<count> issues)
  <file>:<line> — <description>
    TWINS: searched <pattern> — found <N> other sites: <files, or "none">
    Suggested fix: <actionable fix>

MINOR (<count> issues)
  <file>:<line> — <description>
    Suggested fix: <actionable fix>

Summary: <N> CRITICAL, <N> MAJOR, <N> MINOR
Verdict: <PASS|FAIL|SKIP>
```

Omit empty severity sections (e.g., if no CRITICAL issues, don't print the CRITICAL section).
Omit the `INTENT:` line when the diff changes no existing behavior. `TWINS:` lines appear only
under CRITICAL and MAJOR issues, never under MINOR.

If Grade is A, output:
```
Grade: A

No issues found.

Summary: 0 CRITICAL, 0 MAJOR, 0 MINOR
Verdict: PASS
```
