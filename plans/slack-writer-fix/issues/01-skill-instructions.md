## TLDR

Fix language default, stale clipboard, and formatting in SKILL.md instructions.

## What to build

Edit `tools/ai/claude/config/skills/slack-writer/SKILL.md`:

**Language step (new Step 3):**
- Insert a new step between Assess context and Write draft.
- Goal: determine output language. Default English. Switch only if user explicitly requested another language. Input language is not a valid signal.
- Exit criterion: model states the chosen language (e.g., "Language: English").
- Renumber all subsequent steps.

**Common Rationalizations:**
- Add: "The input is in French so I'll write in French" → "Input language is not a valid signal. Default English. Switch only on explicit user request."

**Checklist:**
- Add: language verified (English unless explicitly requested otherwise).

**Finalize step loop:**
- Add instruction at end of Finalize: "If the user requests changes, edit the draft, then re-run Steps 5-6."

**Formatting allowlist (principle 3 — Scannable):**
- Rewrite to include an explicit allowlist: bullets, numbered lists, `code` backticks. Nothing else (no bold, no links, no headers).

## Acceptance criteria

- [ ] New Step 3 (Language) exists with visible decision exit criterion
- [ ] Steps renumbered: 1-Setup, 2-Assess, 3-Language, 4-Write, 5-Lint, 6-Finalize
- [ ] Common Rationalizations table covers input-language-is-not-a-signal
- [ ] Checklist includes language verification
- [ ] Finalize step has loop instruction for post-edit clipboard refresh
- [ ] Principle 3 has formatting allowlist (bullets, numbered lists, code backticks only)
