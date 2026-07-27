---
name: codex-delegation
description: How to hand implementation, review, or a second opinion to Codex (gpt-5.6) — model and effort selection, burn rules, and how to write a spec it will follow. Use when delegating work via `codex exec` or the `/codex` skill.
---

# Delegating to Codex

Codex is installed: `codex exec` for implementation, `/codex` for review/challenge/consult.
It is highly steerable, so output quality tracks spec quality.

## Writing the spec

- Hand it a **decided, bounded plan**, not an open question: exact files, exact behavior,
  constraints, and how you'll verify. It follows instructions literally — ambiguity produces
  wrong output.
- You own the spec and the acceptance check. Delegate the typing, keep the judgment.
- Always review and test what comes back.
- **Give explicit stop points.** 5.6 runs end-to-end and overshoots. "Write the plan, then stop
  for feedback." "Address the first round of review comments, then stop."

Good jobs: self-contained functions/modules from a clear spec, mechanical refactors across many
files, boilerplate, test scaffolding.
Bad jobs: fuzzy design decisions, anything where requirements aren't nailed down yet.

## Model selection

| Model | When |
|---|---|
| `gpt-5.6-terra` | **Default for most work.** `high` on the $200 tier, `low` otherwise. `medium` is good for quick reviews and for maximizing usage. |
| `gpt-5.6-sol` | High-level reasoning, planning, reviewing — the calls where extra depth pays off. |
| `luna` | Don't hand-select. It's for code and for `sol` to spawn as a subagent; leave it to auto-routing. |

All three beat Sonnet/Opus on intelligence-per-cost.

Set the model in `~/.codex/config.toml`, not with `-m` — model pins return 400 under
ChatGPT-account auth.

## Effort and burn

5.6 runs *long* — one message can burn far more than 5.5 did, unpredictably. These rules exist to
get more done per 5-hour window, not to cap intelligence.

- **Effort: medium or high.** `xhigh` is capable but rarely needed, even when orchestrating
  subagents. **Never use Ultra** — despite the UI it is not a reasoning level, and current harness
  bugs make it spawn far too many subagents at far too high reasoning.
- **Fast mode: off.** It costs 2.5× credit, and since 5.6 already runs long a single fast-mode
  message can eat ~40% of a 5-hour window.
- **Subagents inherit the parent.** `terra` always spawns subagents at the parent's model and
  reasoning level — this is why Ultra explodes. Keep parent reasoning modest when subagents are
  likely (`high` is fine, `low`/`medium` better).

## Driving `codex exec` from a script

Read [CODEX-INVOCATION.md](CODEX-INVOCATION.md) before writing any Bash that shells out to
`codex exec`. It's the invocation contract: stdin-file prompts (an argv prompt hangs forever under
a non-TTY harness), capture-then-parse instead of piping the stream, fresh output path per round,
resume by explicit thread id, and re-forcing `sandbox_mode` on resume — `resume` rejects `-s`, so a
review session can silently start writing files. Every trap in that file fails in a way that looks
exactly like success, which is why guessing at the invocation is expensive.
