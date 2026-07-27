# Codex invocation contract

How to drive `codex exec` from a Bash tool without silently corrupting your own results. These are
traps, not preferences — each line below exists because the failure mode it prevents *looks exactly
like success*. Installed here: codex-cli 0.145.0. Floor: >= 0.130.

Patterns adapted from [NulightJens/rocket-fuel-skill](https://github.com/NulightJens/rocket-fuel-skill)
(`CODEX-INTEGRATOR.md`), which verified them live on 0.143.0.

## Non-negotiables, every call

1. **Prompt goes in on stdin from a file** (`- <"$FILE"`), never as an argv string. This kills two
   traps at once: shell-quoting bugs, and the stdin hang — `codex exec` reads stdin *in addition
   to* an argv prompt, so under a non-TTY harness an unredirected call blocks forever at 0% CPU.
   If you must pass an argv prompt, append `< /dev/null`.
2. **`2>/dev/null` always.** Codex streams thinking tokens to stderr; unredirected they flood your
   context. When a call fails, rerun the identical command *without* it to capture the real error.
3. **Capture the JSONL stream to a file, parse after exit.** Never pipe the live stream through
   `grep` — `grep -m1` exits at first match, closes the pipe, and can kill Codex mid-run before it
   writes the output file.
4. **`--json -o <outfile>`.** Read the answer from the `-o` file. Parse the stream file only for
   the thread id.
5. **Fresh temp dir per run, fresh filename per round** (`RUN=$(mktemp -d /tmp/cdx.XXXXXX)`).
   Never reuse an output path across rounds: after a timeout, a reused path serves the *previous*
   round's answer and is indistinguishable from success.
6. **Resume by explicit thread id, never `--last`.** Resuming the wrong session looks like success.
7. **Don't pass `-m`.** Model pins return 400 under ChatGPT-account auth. Set `model` in
   `~/.codex/config.toml` instead, and echo the active model before round 1 (or say "Codex CLI
   default" if unset) so the run is reproducible. See the model table in `SKILL.md` for *what* to
   pick; this is only about *how* to set it.
8. **`timeout: 600000`** (10 min) on the Bash call. Codex writes output only at completion, so a
   killed call is silently empty, not partial.
9. **`--skip-git-repo-check`** on every call. Codex refuses untrusted directories without it.
10. **Snapshot before every call.** All three lines together, in every invocation:

    ```bash
    snap() { git status --porcelain > "$RUN/pre-$1.txt"; git diff > "$RUN/pre-$1.patch";
      git ls-files --others --exclude-standard -z | xargs -0 shasum > "$RUN/pre-$1.sha" 2>/dev/null || true; }
    ```

    If a read-only call changed files anyway: revert paths that were **clean** before. For paths
    that were already tracked-dirty or untracked and no longer match the snapshot, **stop and
    surface it** — never auto-revert. The uncommitted work may be yours.
11. A stream event about "skills context budget" is benign Codex housekeeping, not a failure.

## Read-only calls (review, consult, second opinion)

```bash
RUN=$(mktemp -d /tmp/cdx.XXXXXX)
# write the prompt to "$RUN/prompt-r1.md" first
snap r1
codex exec -s read-only --skip-git-repo-check --json -o "$RUN/out-r1.txt" \
  - <"$RUN/prompt-r1.md" > "$RUN/stream-r1.jsonl" 2>/dev/null
THREAD_ID=$(grep -m1 '"type":"thread.started"' "$RUN/stream-r1.jsonl" \
  | sed 's/.*"thread_id":"\([^"]*\)".*/\1/')
```

Echo `THREAD_ID` visibly, then resume the same session for later rounds.

**The safety line:** `resume` rejects `-s`. Without `-c sandbox_mode="read-only"` Codex inherits
the config default and **can write files mid-review**.

```bash
snap rN
codex exec resume "$THREAD_ID" -c sandbox_mode="read-only" --skip-git-repo-check --json \
  -o "$RUN/out-rN.txt" - <"$RUN/prompt-rN.md" > "$RUN/stream-rN.jsonl" 2>/dev/null
```

## Write calls (implementation)

Baseline the tree first: `git status --porcelain` must be **empty** when Codex launches, so the
resulting diff is exactly Codex's work and nothing else. Commit or stash your own work first —
if pre-existing dirty files aren't yours to commit, stop and ask rather than sweeping them into
a baseline commit (they may be secrets or scratch files).

Default to Codex's own sandbox. Do **not** reach for `--yolo` /
`--dangerously-bypass-approvals-and-sandbox` — sandboxed mode builds real features, and the bypass
flags run an unsandboxed agent, which needs explicit per-run approval from the user.

```bash
snap build   # pre-build.txt must be empty
codex exec --sandbox workspace-write --full-auto --skip-git-repo-check --json \
  -o "$RUN/build-out.txt" - <"$RUN/spec.md" > "$RUN/stream-build.jsonl" 2>/dev/null
BUILD_THREAD=$(grep -m1 '"type":"thread.started"' "$RUN/stream-build.jsonl" \
  | sed 's/.*"thread_id":"\([^"]*\)".*/\1/')
```

Needs network to install deps? Add `-c sandbox_workspace_write.network_access=true` and say so
before running. Fix rounds resume the same thread with the sandbox re-forced via `-c`:

```bash
snap fixN
codex exec resume "$BUILD_THREAD" -c sandbox_mode="workspace-write" --skip-git-repo-check --json \
  -o "$RUN/fix-outN.txt" - <"$RUN/fixN.md" > "$RUN/stream-fixN.jsonl" 2>/dev/null
```

Cap fix rounds at 2. Still broken after that, take the wheel yourself — don't keep feeding it.
Codex never commits; you do.

## Did it actually succeed?

A call succeeded only if **all** of: exit code 0, the round's `-o` file exists and is non-empty,
and it contains the terminal marker your prompt asked for (e.g. a `VERDICT:` line). Anything less
is a failure even if the stream showed `thread.started`. **Never read an answer from a file the
current round did not freshly write.**

Review what comes back as a claim, not evidence: `git diff --stat` first, read every hand-written
source change in full (skip lockfiles and generated output), and run the verification command
yourself. Only your own run counts.

## Failure ladder

- **Fresh call failed or timed out, no thread id captured:** retry once with a fresh session and a
  new round filename. Never `resume` a thread that never started.
- **Resume failed or timed out:** retry once with the same explicit thread id and a new filename.
  On the second failure, fall back to a fresh session carrying a one-paragraph summary — and say so,
  because the new session cannot verify its own prior findings.
- **Still failing:** stop and surface the error (rerun without `2>/dev/null`). Never continue as if
  the review happened.
- **Auth error:** `codex login`. **`spawn ... ENOENT`:** `npm i -g @openai/codex@latest`.
