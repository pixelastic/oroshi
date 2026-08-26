---
name: cfp-writer
description: Use when user needs to write or review a Call for Paper, submit a talk proposal, or transform existing content into conference-ready format. Crafts compelling CFP submissions (title, abstract, takeaways) and reviews existing drafts with voice preservation.
---

# CFP Writer

## Overview

Transform talk materials into conference-ready CFP submissions. Two modes:
**create** (new CFP from materials) and **review** (improve an existing draft
while preserving the speaker's voice).

## Utilities

**`cfp-writer-tick <draftPath>`** — Call whenever output is displayed to the
user, across all steps. Not tied to any single step. The draft file contains
whatever the user asked to see — title only, abstract only, or full submission.

## Core Workflow

### Step 1 — Mode detection

**Goal:** Determine whether this is a create or review session.

**Exit criterion:** Mode stated to user.

Read the user's input. Two modes:
- **Review** — user has an existing CFP draft (theirs or a colleague's) that needs improvement
- **Create** — user has materials (slides, outline, idea) and needs a new CFP

State the detected mode: "Mode: **create**" or "Mode: **review**".

### Step 2 — Gather

**Goal:** Understand the talk content, constraints, and existing quality.

**Exit criterion:** Talk essence extracted, constraints known.

1. **Ask what the user has** — slides, outline, idea, existing draft, colleague's draft. If file path provided, read it directly.

2. **Ask for CFP constraints** — target conference, language (French or English), word limits, specific themes.

3. **Extract talk essence** — main problem, key technical concepts, audience level, unique angle, real examples or outcomes.

4. **Read `EXAMPLES.md`** for inspiration on structure, tone, and specificity.

5. **If review mode:** Analyze the existing draft critically — hook strength,
   structure clarity, concrete examples, named technologies, buzzwords, value
proposition.

### Step 3 — Title

**Goal:** Create a compelling, clear title

**Exit criterion:** User selects or refines a title.

Read `references/title-patterns.md`. Generate 3-5 title options using the proven
patterns. Iterate until user selects.

### Step 4 — Abstract

**Goal:** Write a ~250-word abstract with key takeaways.

**Exit criterion:** User approves abstract and takeaways.

Read `references/abstract-structure.md`. Write the abstract using the four-part
structure (Hook → Context → Content → Takeaway). Generate 3-5 key takeaways.

**If review mode:** Read `references/voice-preservation.md`. Restructure and
reorder freely, but do not rewrite sentences that already work.

### Step 5 — Review

**Goal:** Verify quality and iterate until user approves.

**Exit criterion:** User approves the final output.

1. **Write draft to `draftPath`.**

2. **Run prose linting:**
   ```
   prose-lint --profile cfp-writer <draftPath>
   ```
   Zero errors required. Warnings addressed as best effort. Fix `draftPath`, re-lint, repeat until clean.

3. **Run verification checklist:**
   - [ ] Title is under word limit and uses a proven pattern
   - [ ] Abstract follows Hook → Context → Content → Takeaway structure
   - [ ] Abstract is within word count (~250 words, or specified limit)
   - [ ] Abstract includes concrete examples or numbers
   - [ ] Takeaways are specific, actionable, start with verbs
   - [ ] Tone is professional but accessible
   - [ ] Content accurately represents the actual talk

4. **Present final output** and ask user: approve or request edits.
   - If edits requested → loop back to the relevant step.
   - If approved → move to Step 6.

### Step 6 — Self-improvement

**Goal:** Capture strong patterns for future sessions.

**Exit criterion:** User asked, examples updated or skipped.

Reflect on the session. If a strong pattern emerged (effective hook, novel structure, compelling before/after transformation):

Ask the user whether to add it to `EXAMPLES.md`. Do not append without explicit approval.

If approved, add to the appropriate section:
- **Standalone** — for new reference examples
- **Before / After** — for transformation pairs from review sessions

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I don't need to follow Hook → Context → Content → Takeaway" | This structure is validated across thousands of successful CFPs. Skipping it gets rejected. |
| "I'll rewrite this sentence to sound better" | In review mode, preserve the speaker's phrasing. Don't rewrite sentences that already work. |

## Checklist

- [ ] Mode detected and stated (create or review)
- [ ] `EXAMPLES.md` read for inspiration
- [ ] Talk essence extracted, constraints known
- [ ] At least 3 title options generated
- [ ] Abstract follows Hook → Context → Content → Takeaway
- [ ] Voice-preservation rules applied (review mode)
- [ ] Draft written to `draftPath`
- [ ] `prose-lint --profile cfp-writer` returns zero errors
- [ ] `cfp-writer-tick <draftPath>` called when output displayed
- [ ] Verification checklist completed
- [ ] User asked whether to add patterns to `EXAMPLES.md`
