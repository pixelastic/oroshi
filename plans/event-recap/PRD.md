## Problem Statement

Tim hosts monthly meetups at Algolia's Paris office. After each event, he needs to post an org recap to his team on Slack — attendance, what went well, what was learned, action items. This is manual, time-consuming, and often forgotten. The recap format follows the AAR (After Action Review) structure but there's no tool to go from raw notes to a polished message.

## Solution

A `/meetup-recap` skill that takes a raw speech-to-text dump of post-event notes and produces a Slack-ready org recap message. The skill infers structure from the dump, asks targeted follow-up questions for missing mandatory info, scores the meetup on a 10-item rubric, and iterates with the user until the message is approved.

## User Stories

1. As Tim, I want to dump raw speech-to-text notes after a meetup, so that I don't have to structure my thoughts while they're still fresh.
2. As Tim, I want the skill to ask me only about truly missing info (event name, date, attendance), so that the follow-up round is fast.
3. As Tim, I want the skill to categorize my notes into "what went well / what we learned / for next time" sections, so that I don't have to sort them myself.
4. As Tim, I want a "Tim score" (0-10) based on a fixed rubric, so that I can compare meetups objectively over time.
5. As Tim, I want the score emoji (red/green/medal) in the intro, so that readers immediately know how it went.
6. As Tim, I want the recap in my clipboard at every iteration, so that I can paste it into Slack the moment I'm satisfied.
7. As Tim, I want to review the draft and request edits in a loop, so that the final message matches my voice.
8. As Tim, I want the output to always be in English regardless of my input language, so that my international team can read it.
9. As Tim, I want prose-lint to catch generic writing issues, so that the message is clean before I see it.
10. As Tim, I want the skill to offer a handoff to `/talk-recap` after I approve, so that I can optionally summarize the talks too.
11. As Tim, I want the recap to follow inverted-pyramid structure, so that readers who only read the intro still get the essential info.
12. As Tim, I want numbers and concrete facts instead of vague impressions, so that the recap serves as a brag document for the team.

## Implementation Decisions

### Skill file

- Location: `tools/ai/claude/config/skills/meetup-recap/SKILL.md`
- No `references/` directory — tone and format rules encoded directly in SKILL.md
- No gold standard example file — the agent must follow rules, not copy an example

### Session scripts

- `meetup-recap-start` — initializes session, outputs JSON `{"draftPath": "..."}` (same pattern as `slack-writer-start`)
- `meetup-recap-tick` — copies current draft to clipboard (called at every loop iteration, not just at the end)
- No `meetup-recap-end` — skill ends naturally after user approval

### Scoring rubric (10 items, +1 each)

1. Had an internal (Algolia) speaker
2. Someone helped organize
3. Enough food & drinks
4. Good turnout ratio (>60% of registered)
5. Talks relevant to Algolia's domain
6. Found the talks interesting
7. Attendees expressed interest in working at Algolia
8. No major logistics issues (AC, AV, etc.)
9. Badge system worked
10. Streaming/recording worked

Thresholds: red 0-4, green 5-8, medal 9-10.
Score displayed in intro as: "Tim score: 🟢 7/10"

### Writing principles (encoded in SKILL.md)

1. **Important thing first.** Inverted pyramid: the intro paragraph is the whole story in miniature — event, turnout, one-sentence verdict. If the reader stops there, they know how it went. Each section below adds depth. No section should contain a surprise that contradicts the intro.
2. **Scannable.** The reader gets the gist by reading the intro and glancing at the bullet points. Use numerals for all numbers (60, not sixty) — they catch the scanning eye. Formatting: bullets, numbered lists, `code` backticks, whitespace. No bold, no links, no headers.
3. **Compress.** Every bullet must carry a fact, an outcome, or a lesson. No filler ("it was great", "overall a good experience"). If a bullet doesn't teach the reader something they didn't know, delete it. Say it once — no repetitions across sections.
4. **Quantify.** Use numbers everywhere they exist: attendance ratio, number of talks, talk duration, how many pizzas, how many drinks. A number is always more informative than "a lot" or "several". If the user gave a number in their dump, it must appear in the output.
5. **Honest.** State problems as facts: "soft drinks were expired", "not enough pizzas for 60 people." State what happened, not who caused it.
6. **Sound human.** Write like telling a colleague what happened over coffee. Parenthetical asides are welcome ("better no-show rate than most meetups"). Emoji sparingly — one or two per message max. No corporate phrasing ("we successfully hosted", "the event was a success").

### Output structure

```
Intro: event name, date, attendance ratio, Tim score (emoji X/10), format note
[blank line]
What went well
• bullets (if 2+), sentence (if 1), skip (if nothing)
[blank line]
What we learned
• bullets/sentence/skip
[blank line]
For next time
• bullets/sentence/skip
[blank line]
Closing line
```

"What we learned" contains real problems as facts. "For next time" contains the fixes.

### Mandatory fields (asked if missing from dump)

- Event name
- Date
- Attendance (registered vs. showed up)

All other content is inferred from the dump.

### Flow

1. Gather dump
2. Ask missing mandatory fields (batched in one message)
3. Write draft (with inferred score) → lint (`--profile meetup-recap`) → `meetup-recap-tick` (clipboard) → show draft → ask confirmation
4. If edits requested: loop back to step 3
5. After approval: "Summarize talks too, or stop here?" → optionally invoke `/talk-recap`

### Language

Always English. Input language is not a signal.

### Prose-lint profiles

- Create `meetup-recap` profile (inherits default, no overrides initially)
- Create `slack-writer` profile (inherits default, no overrides initially)
- Update `slack-writer/SKILL.md` to use `--profile slack-writer`
- Profile names match skill names

### Slack-writer updates

- Rename `slack-writer-end` → `slack-writer-tick` (same clipboard-at-every-iteration pattern)
- Update slack-writer SKILL.md: replace `slack-writer-end` with `slack-writer-tick`, add iteration loop to the flow

## Testing Decisions

- Session scripts (`meetup-recap-start`, `meetup-recap-tick`): tested with bats (same pattern as slack-writer scripts)
- Prose-lint profiles: tested by running `prose-build` and verifying the generated `.ini` files exist and contain expected content
- Skill file: no automated test — validated by manual invocation
- Slack-writer rename: update existing tests from `slack-writer-end` to `slack-writer-tick`

## Out of Scope

- `/talk-recap` skill (separate sidequest, already created in tab `talk-recap`)
- Custom Vale rules specific to meetup-recap (profiles start as default copies)
- Scoring rubric persistence/tracking across meetups (future feature)
- Meetup page URL scraping or API integration
- Conference recap (different skill for non-hosted events)

## Further Notes

- The scoring rubric is inferred from the dump and written into the draft directly. No separate confirmation step — if the score is wrong, the user corrects it in the normal edit loop.
- The AAR (After Action Review) format descends from US Army doctrine (1970s). The positive reframing ("what we learned" vs "what went wrong") comes from Appreciative Inquiry (Cooperrider, 1987).
- Research sources: Julia Evans (brag documents), NNGroup (scannable writing), Barbara Minto (pyramid principle), swyx (DevRel post-event practices).
