@RTK.md

Be brief.

## Model Orchestration

Daily driver: **Fable at `high` effort** (`settings.json`: `model: claude-fable-5[1m]`, `effortLevel: high`). Fable is the main-loop orchestrator. It plans, steers, decides, and synthesizes. Push everything token-hungry or mechanical off its context onto cheaper models or Codex, then have those report distilled results back.

Effort rules: Fable runs on `high`. Do not reach for `xhigh` (token-hungry) or `max`/extra (a furnace, worse outputs than lower tiers). For subagents, set effort per-call: `low`/`medium` for mechanical work, `high` only for real reasoning.

### Who does what

| Work | Model | Why |
| ---- | ----- | ----- |
| Orchestration, planning, steering, final synthesis, user-facing decisions | **Fable** (main loop, high) | Steering and judgment are Fable's strength; keep its context clean |
| Codebase analysis, broad search, "where is X", reading many files | **Haiku** (Sonnet if it needs reasoning) via `Explore`/subagent | Context-polluting and cheap to do elsewhere; return conclusions, not file dumps |
| Computer use, browser, screenshots, log/output scraping | **Haiku/Sonnet** subagent (web browsing still goes through `/browse`) | Inherently token-hungry; do it out-of-band and report back |
| Bulk mechanical edits, classification, transforms, verification runs | **Haiku** (low/medium effort) | No reasoning needed; fast and cheap |
| Well-specified implementation, second opinions, adversarial review | **Codex / GPT-5.5** (`codex exec`, `/codex`) | Extremely steerable; Fable writes the spec and reviews the output |
| Genuinely hard architecture / subtle root-cause debugging, or Fable stuck after ~2 tries | **Opus** (high, escalate only) | Deepest reasoning, but token-expensive; never the default |

Pass the model explicitly when spawning: `Agent(..., model: "haiku")`, or in `Workflow`: `agent(prompt, { model: "haiku", effort: "low" })`. Subagents inherit the main-loop model (Fable) unless their agent definition pins one or you override, so a token-hungry job with no override defeats the purpose.

### Keep Fable's context clean

Anything that would flood the main context with raw material (large file reads, search sweeps, computer/browser use, log analysis) goes to a Haiku or Sonnet subagent that returns only the distilled answer. Fable sees the conclusion, never the dump. That is where the token savings and the no-rate-limit workflow come from: expensive tokens get spent on a cheap model, and Fable stays fast.

### Codex (GPT-5.5) as an implementation fallback

Codex is installed (`codex exec` for implementation, `/codex` skill for review/challenge/consult). It is highly steerable, so output quality tracks spec quality. To steer it well:

- Hand it a **decided, bounded plan**, not an open question: exact files, exact behavior, constraints, and how you'll verify. It follows instructions literally, so ambiguity produces wrong output.
- Fable owns the spec and the acceptance check. Delegate the typing, keep the judgment.
- Always review and test what Codex returns before accepting it.
- Use `/codex` in challenge/review mode for a genuinely independent second opinion on Fable's own work.

Good Codex jobs: self-contained functions/modules from a clear spec, mechanical refactors across many files, boilerplate, test scaffolding. Bad Codex jobs: fuzzy design decisions, anything where requirements aren't nailed down yet.

### Rules of thumb

- NEVER USE HAIKU FOR ANYTHING.
- Use `gh-axi` for GitHub and `chrome-devtools-axi` for browser automation (token-efficient AXI CLIs; fall back to `gh`/MCP only if a subcommand is missing).
