## TLDR

Create the `/meetup-recap` skill definition.

## What to build

Create `tools/ai/claude/config/skills/meetup-recap/SKILL.md` with:

**Frontmatter:**
- `name: meetup-recap`
- `description`: triggers on post-meetup recap requests

**Workflow (6 steps):**

1. **Setup** — Run `meetup-recap-start`, parse JSON for `draftPath`
2. **Gather** — Read the user's dump. Identify missing mandatory fields (event name, date, attendance). If any missing, ask all in one batched message. Infer scoring rubric from dump.
3. **Language** — Always English. Input language is not a signal.
4. **Write draft** — Apply the 6 writing principles (important first, scannable, compress, quantify, honest, sound human). Follow the output structure (intro with Tim score → what went well → what we learned → for next time → closing). Categorize user's raw notes into the appropriate sections. Write to `draftPath`.
5. **Lint** — Run `prose-lint --profile meetup-recap <draftPath>`. Fix errors, re-lint until zero errors.
6. **Tick** — Run `meetup-recap-tick <draftPath>`. Display the draft. Ask user for confirmation. If edits requested, loop back to step 4. If approved, ask "Summarize talks too, or stop here?" — if yes, invoke `/talk-recap`.

**Scoring rubric** (encoded in SKILL.md):
10 criteria, +1 each. Thresholds: 🔴 0-4, 🟢 5-8, 🏅 9-10.
Displayed in intro as "Tim score: 🟢 7/10".

**Writing principles** (encoded in SKILL.md):
1. Important thing first (inverted pyramid, intro stands alone)
2. Scannable (numerals, bullets, whitespace, no bold/headers)
3. Compress (every bullet = fact/outcome/lesson, no filler, say it once)
4. Quantify (numbers everywhere they exist)
5. Honest (problems as facts, no blame)
6. Sound human (like telling a colleague over coffee, parenthetical asides, 1-2 emoji max)

**Output structure:**
```
Intro: event name, date, attendance ratio, Tim score, format note
[blank line]
What went well
• bullets (2+) / sentence (1) / skip (nothing)
[blank line]
What we learned — real problems as facts
• bullets / sentence / skip
[blank line]
For next time — the fixes
• bullets / sentence / skip
[blank line]
Closing line
```

**Common Rationalizations and Checklist** following the skill template pattern.

## Acceptance criteria

- [ ] `tools/ai/claude/config/skills/meetup-recap/SKILL.md` exists with valid frontmatter
- [ ] All 6 workflow steps have Goal and Exit criterion
- [ ] All 6 writing principles encoded
- [ ] Scoring rubric with 10 criteria and 3 thresholds encoded
- [ ] Output structure template encoded
- [ ] Mandatory fields list (event name, date, attendance) encoded
- [ ] Common Rationalizations table present
- [ ] Checklist present
