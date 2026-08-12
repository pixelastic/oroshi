---
name: meetup-recap
description: Use when user wants to write a post-meetup recap — transforming raw notes or brain dump into a structured, honest summary.
---

# Meetup Recap

## Overview

Transform raw post-meetup notes (often speech-to-text) into a structured, honest recap. Score the event, categorize observations, and produce a scannable summary ready for sharing.

## Core Workflow

### Step 1 — Setup

**Goal:** Initialize a draft session.

**Exit criterion:** `draftPath` obtained.

Run `meetup-recap-start` and parse the JSON output to get the `draftPath`.

### Step 2 — Gather

**Goal:** Collect all mandatory information from the user's dump.

**Exit criterion:** Event name, date, and attendance ratio are known.

Read the user's input (brain dump, file, conversation context). Identify mandatory fields:
- **Event name** — the meetup/event title
- **Date** — when it happened
- **Attendance** — ratio or count (e.g., "12/15", "~20 people")

If any mandatory fields are missing, ask for all missing ones in a single batched message. Do not ask one at a time.

### Step 3 — Score

**Goal:** Compute a score from the user's dump.

**Exit criterion:** Score computed with emoji threshold.

Read [references/scoring.md](references/scoring.md) for criteria, defaults, and thresholds. Score the dump accordingly.

### Step 4 — Language

**Goal:** Determine output language.

**Exit criterion:** Language stated (e.g., "Language: English").

Default to English.
Switch to french only if user explicitly request it.
Input language is not a signal.

### Step 5 — Write draft

**Goal:** Produce a structured recap saved to `draftPath`.

**Exit criterion:** Draft file written to disk.

Write the draft following the [writing principles](references/writing-principles.md) and the [recap template](references/templates/recap.template.md).

Write the draft to `draftPath`.

### Step 6 — Lint

**Goal:** Ensure the draft passes prose linting.

**Exit criterion:** Zero errors.

Run `prose-lint --profile meetup-recap <draftPath>` to get a JSON array of violations.

Loop: fix `draftPath` (using the Edit tool), re-lint. Repeat until zero errors remain. Warnings may stay if justified.

### Step 7 — Tick

**Goal:** Present draft and get user confirmation.

**Exit criterion:** User approves or requests edits.

1. Run `meetup-recap-tick <draftPath>`.
2. Display the draft.
3. Ask user for confirmation.

If edits requested, loop back to Step 5.

If approved, ask: "Summarize talks too, or stop here?" — if yes, invoke `/talk-recap`.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user prompted in French so I'll write in French" | Default to English. Switch only on explicit request. |
| "The event was bad so I'll soften the language" | State problems as facts. Honest > comfortable. |
| "I'll add bold and headers to make it pop" | Scannable means bullets and whitespace, not formatting soup. |

## Checklist

- [ ] `draftPath` obtained from `meetup-recap-start`
- [ ] Event name, date, and attendance confirmed
- [ ] Language verified (English unless explicitly requested otherwise)
- [ ] All 6 writing principles applied
- [ ] Score computed
- [ ] Output structure followed
- [ ] `prose-lint --profile meetup-recap` returns zero errors
- [ ] `meetup-recap-tick` called with `<draftPath>`
- [ ] User confirmed or edits applied
