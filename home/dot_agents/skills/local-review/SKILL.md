---
name: local-review
description: "Structured walkthrough of the current branch's changes for developer understanding before PR creation. NOTE: this skill is NOT intended to be dynamically loaded or automatically triggered; it should only ever be explicitly invoked by the user."
---

# Local Review: Pre-PR Walkthrough

Provide a structured walkthrough of all changes on the current branch so the developer understands the implementation before creating a PR. This is knowledge transfer, not code review — the developer knows the architectural intent but needs to understand how the code implements it.

## Phase 1: Pre-flight

Run the bundled metadata-gathering script. It ships alongside this skill in this skill directory's `scripts/` folder. Invoke it using the absolute path to this skill's `scripts/review-context.sh` (the same directory this SKILL.md was loaded from). It operates on the current git repo — the developer's working directory — not on the skill directory, so run it without changing directories:

```bash
bash <path-to-this-skill>/scripts/review-context.sh
```

Parse the JSON output and handle the status:

- `"error"` — Display the message and stop. Do not proceed.
- `"warning"` — Display the warning and ask if the developer wants to continue.
- `"ok"` — Proceed to Phase 2.

Display a brief orientation: branch name, number of commits, number of files changed, whether uncommitted changes are included.

## Phase 2: Overview

Group the changed files into logical concerns. Follow these rules:

### Grouping

- Group by what the files accomplish together, not by directory or file type.
- If a component and its test file both changed, group them together — the test supports understanding the component.
- Only create a standalone "Tests" group for test files whose corresponding implementation did NOT change.
- A single file can only belong to one group.

### Ordering

Order groups by dependency — foundational changes first, consumers last:

1. Types, schemas, and interfaces
2. Data layer (API routes, lib modules, data access)
3. Business logic and utilities
4. UI components and pages
5. Standalone tests
6. Configuration and tooling

If one group's changes are required for another group to make sense, the prerequisite group comes first regardless of the ordering above.

### Present the table of contents

Display a numbered list. For each group show:

- Group name
- Files in the group (short paths)
- One-line description of what this group accomplishes

Then STOP. Do not begin the walkthrough until the developer responds. They may:

- Proceed in order
- Reorder groups
- Skip specific groups
- Ask questions about the grouping

## Phase 3: Walkthrough

Walk through one group at a time. For each group, present three sections:

### 1. What changed

Bullet list of each file in the group with its change status:

- **(A)** Added — new file
- **(M)** Modified — existing file changed
- **(D)** Deleted — file removed

### 2. How it works

Explain the implementation. This is the core of the walkthrough — the narrative that gives the developer the understanding they would have if they wrote this code themselves.

- Describe the approach: what does this code do and how does it do it?
- Trace data flow and control flow through the changed code.
- Explain how the pieces in this group connect to each other and to the rest of the codebase.
- Read the actual source files to give accurate explanations — do not rely solely on the diff.
- Pitch the explanation at implementation level, not architecture level. The developer already knows the architecture.

### 3. Non-obvious details

Bullet list of implementation choices that are NOT self-evident from the architectural intent:

- Why a specific pattern or data structure was chosen
- Ordering dependencies or sequencing that matters
- Implicit contracts or assumptions in the code
- Edge cases that are handled (or deliberately not handled)

If there are no non-obvious details, say so briefly and move on.

### After each group

STOP. Present these options and wait for the developer's response:

- **Next** — proceed to the next group
- **Questions** — the developer wants to ask about this group
- **Jump to [N]** — skip to a specific group number
- **Note for fix** — flag something in this group for fixing later

Do not proceed to the next group until the developer responds.

## Phase 4: Summary

After all groups have been walked through (or skipped), present:

### Groups reviewed

A table showing each group and whether it was reviewed or skipped.

### Next steps

Ask the developer what they would like to do:

- Proceed to local verification
- Proceed to PR creation
- Go back and review a specific group again

## Phase 5: Local Verification

Generate a set of hands-on verification steps the developer can perform locally to confirm the implementation works correctly. These steps must be derived from the actual changes on the branch — do not use a generic checklist. Only include sections that are relevant to what changed.

### 1. Test integrity

Help the developer confirm that the tests are actually testing the right things, not just passing.

- For each new or modified test file, identify the key assertions and suggest one or two specific assertions the developer can temporarily break (change an expected value, remove a mock return) to prove the test catches real failures. Be specific: name the test, the line, and what to change.
- Call out any tests that only verify rendering without asserting on behavior or output (e.g., "renders without crashing" with no further assertions). These are not necessarily wrong, but the developer should know they exist.
- If mocks are used, note what is being mocked and whether the mock setup faithfully represents the real dependency's contract. Flag any mocks that return hardcoded values where the real dependency's behavior is more complex.

### 2. Visual verification

Include this section only when the changes affect UI components or pages.

- Provide the exact navigation path to reach the affected UI (e.g., "Start the dev server, go to `/certifications`, click any employee row").
- Describe what specifically to look at — not "verify it works" but concrete observations (e.g., "The filter badge count in the sidebar should update when you toggle a filter. With two filters active, the badge should read '2'.").
- If the change is a before/after difference, describe what the developer would have seen before and what they should see now.
- Note any relevant mock data scenarios if using `USE_MOCKS=true`, and whether the mock data exercises the new behavior.

### 3. Data and API verification

Include this section only when the changes affect API routes, lib modules, data fetching, or caching.

- Provide curl commands or browser URLs the developer can use to hit affected endpoints directly. Include any required headers, query parameters, or request bodies.
- Describe the expected response shape with example values for key fields.
- If validation logic changed, provide at least one valid and one invalid request payload so the developer can confirm both the happy path and the rejection.
- If caching behavior changed, describe how to observe it (e.g., "Hit the endpoint twice within 10 seconds — the second response should come from cache. Check the `x-cache` header or add a `console.log` in the cache lookup.").

### 4. Integration point verification

Include this section only when the changes cross architectural boundaries (e.g., new API route consumed by a new SWR hook consumed by a new component).

- Describe how to confirm the wiring between layers works end-to-end. Be specific about what to observe (e.g., "Open the Network tab, navigate to the page, confirm a request to `/api/v1/skills` fires and the component renders the response.").
- If behavior depends on auth state, describe what the developer should see both with and without a valid session.
- If the change involves data flowing through multiple steps, describe the full path and suggest a point where the developer can add a temporary `console.log` to confirm data arrives in the expected shape.

### Presenting verification steps

- Number each step so the developer can reference them.
- For each step, state what to do and what the expected outcome is.
- Keep steps atomic — one action, one observation per step.
- After presenting all steps, STOP and wait for the developer. They may ask questions, skip verification, or report results before moving on.
