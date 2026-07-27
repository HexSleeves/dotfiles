Be brief.

## Model orchestration

Main loop is Opus 5 at `high` effort. Keep its context clean: anything that would flood context
with raw material — large file reads, broad search sweeps, browser/computer use, log scraping —
belongs in a subagent that returns the conclusion, not the dump.

When delegating, pass the model explicitly (`Agent(..., model: "haiku")`,
`agent(prompt, { model: "haiku", effort: "low" })`) — subagents otherwise inherit Opus, which
defeats the point. Haiku at `low`/`medium` for mechanical work and search; Sonnet when it needs
reasoning; `high` only for real reasoning.

Don't reach for `xhigh` (token-hungry) or `max` (worse outputs than lower tiers).

## Codex as a second opinion

Codex (gpt-5.6) is installed and is a genuinely independent reviewer — use it that way. After
non-trivial work, hand it the diff via `/codex` in challenge/review mode and weigh what comes back;
a second model catching your own blind spots is worth more than re-reading your own work. It's also
the right target for well-specified implementation you'd otherwise type yourself.

Load the `codex-delegation` skill for model selection, effort, and how to write a spec it follows.

## Tooling gotchas

- `gh-axi` for GitHub, `chrome-devtools-axi` for browser automation — token-efficient AXI CLIs.
  Fall back to `gh`/MCP only if a subcommand is missing.
- `rtk` proxies dev commands for token savings and is applied automatically by a PreToolUse hook,
  so ordinary commands need no prefix. Call it directly only for its own meta commands:
  `rtk gain` (savings), `rtk gain --history`, `rtk discover`, `rtk proxy <cmd>` (bypass filtering).
