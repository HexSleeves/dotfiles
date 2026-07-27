---
name: stop-slop
description: Remove AI writing tells from prose — READMEs, ADRs, PR and commit bodies, docs, specs, release notes, and long-form explanations. Use when drafting, editing, or reviewing prose you are about to hand to a human. Not for code, and not for rewriting text the user wrote themselves unless they ask.
metadata:
  trigger: Writing or editing prose deliverables (docs, ADRs, PR descriptions, release notes)
  author: Hardik Pandya (https://hvpandya.com) — vendored from github.com/hardikpandya/stop-slop
---

# Stop Slop

Eliminate predictable AI writing patterns from prose.

## Scope

**Applies to:** prose you are authoring for a human reader — READMEs, ADRs, spec and design docs,
PR descriptions, commit message bodies, release notes, and long-form explanation in chat.

**Does not apply to:**

- Code, identifiers, config, or log output. Only prose.
- Text the user wrote. Don't rewrite their voice unless they asked.
- Quoted or cited material, error messages, and API/CLI output — reproduce these verbatim.
- Structured formats whose shape is fixed by a convention or tool (conventional-commit subject
  lines, changelog entry grammar, issue templates, JSON/YAML string fields).

**Don't over-apply.** These rules target unconscious AI defaults, not all repetition or emphasis.
A deliberate parallel structure, a technical term that has no shorter synonym, or a genuinely
three-item list because there are exactly three items — leave them. If a rule would make the
sentence less accurate, accuracy wins. Rewrite for clarity, never to satisfy a checklist.

## Core Rules

1. **Cut filler phrases.** Remove throat-clearing openers, emphasis crutches, and all adverbs. See [references/phrases.md](references/phrases.md).

2. **Break formulaic structures.** Avoid binary contrasts, negative listings, dramatic fragmentation, rhetorical setups, false agency. See [references/structures.md](references/structures.md).

3. **Use active voice.** Every sentence needs a human subject doing something. No passive constructions. No inanimate objects performing human actions ("the complaint becomes a fix").

4. **Be specific.** No vague declaratives ("The reasons are structural"). Name the specific thing. No lazy extremes ("every," "always," "never") doing vague work.

5. **Put the reader in the room.** No narrator-from-a-distance voice. "You" beats "People." Specifics beat abstractions.

6. **Vary rhythm.** Mix sentence lengths. Two items beat three. End paragraphs differently. No em dashes.

7. **Trust readers.** State facts directly. Skip softening, justification, hand-holding.

8. **Cut quotables.** If it sounds like a pull-quote, rewrite it.

## Quick Checks

Before delivering prose:

- Any adverbs? Kill them.
- Any passive voice? Find the actor, make them the subject.
- Inanimate thing doing a human verb ("the decision emerges")? Name the person.
- Sentence starts with a Wh- word? Restructure it.
- Any "here's what/this/that" throat-clearing? Cut to the point.
- Any "not X, it's Y" contrasts? State Y directly.
- Three consecutive sentences match length? Break one.
- Paragraph ends with punchy one-liner? Vary it.
- Em-dash anywhere? Remove it.
- Vague declarative ("The implications are significant")? Name the specific implication.
- Narrator-from-a-distance ("Nobody designed this")? Put the reader in the scene.
- Meta-joiners ("The rest of this essay...")? Delete. Let the essay move.

## Scoring

Rate 1-10 on each dimension:

| Dimension | Question |
|-----------|----------|
| Directness | Statements or announcements? |
| Rhythm | Varied or metronomic? |
| Trust | Respects reader intelligence? |
| Authenticity | Sounds human? |
| Density | Anything cuttable? |

Below 35/50: revise.

The score is your own judgment, not a measurement. Use it to decide whether to revise, and don't
report it as if it were computed.

## Examples

See [references/examples.md](references/examples.md) for before/after transformations.

## License

MIT. Rules and references by Hardik Pandya; the Scope section is a local addition.
