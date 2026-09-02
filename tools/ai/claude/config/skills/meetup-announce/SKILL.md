---
name: meetup-announce
description: Use when user wants to write Slack announcements for an upcoming meetup.
---

# Meetup Announce

## Overview

Generate audience-tailored Slack announcements across multiple channels with a
stateful, multi-invocation timeline. Each invocation picks up where the last
left off, writing one draft at a time through a lint → review → post cycle.

## Core Workflow

### Step 1 — Start

**Goal:** Initialize (or resume) the announcement session.

**Exit criterion:** `meetup-announce-start` JSON parsed, context loaded.

Ask the user for the Airtable record ID if not provided.
Run `meetup-announce-start <recordId>` and parse the JSON output.
It returns:
- `draftDir` — path to the draft directory (contains `state.json` and `assets/`)
- `window` — current window (`early` or `last`)
- `meetup` — meetup metadata (title, date, speakers, programme, venue, registration link)
- `messages` — ordered array of pending messages to write this invocation, each with `id`, `scheduledFor` and `channel`

### Step 2 — Gather context

**Goal:** Understand what needs to be written this invocation.

**Exit criterion:** Message list displayed, user confirms.

Display a summary:
- Current **Window** (Early or Last)
- List of pending **Messages** to write, in order, with their target channel, type, and scheduled date

### Step 3 — Write draft

**Goal:** Produce one Slack-ready **Draft** at a time, saved to the draft directory.

**Exit criterion:** Draft file written to disk.

Pick the next pending **Message** in order.

If the message is a **topic-relevant** **Initial**, ask the user which channel to target — discovered by querying Claude bot in Slack for channels matching the meetup's subject matter.

Apply the [writing principles](references/writing-principles.md) and the [channel briefs](references/channel-briefs.md) for that channel.

Write the draft to `<draftDirectory>/<messageId>.md`.

For `#office-paris` **Initial**: write both main message and thread reply separated by `---`.

### Step 4 — Lint

**Goal:** Ensure the draft passes prose linting.

**Exit criterion:** Zero errors.

Run `prose-lint --profile meetup-announce <draftPath>`.

Loop: fix the draft, re-lint. Repeat until zero errors remain. Warnings may stay if justified.

### Step 5 — Review loop

**Goal:** Get user approval for the draft.

**Exit criterion:** User approves.

Display the draft and ask for approval or edits.
- If edits requested → revise, re-lint, re-display.
- If approved → move to Step 6.

### Step 6 — Mark posted

**Goal:** Update state when user confirms they posted the message.

**Exit criterion:** `state.json` updated.

When the user confirms they posted the message to Slack, update `state.json`: set the message's **State** from `drafted` to `posted`.

### Step 7 — Next message

**Goal:** Continue to the next pending message or wrap up.

**Exit criterion:** All messages for this window processed, or user ends session.

If more pending **Messages** remain for this **Window**, loop back to Step 3.

If all messages for the current window are done, stop.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll write all drafts at once to save time" | One draft at a time. Each needs lint + review before moving on. |
| "The user prompted in French so I'll write in French" | Messages are in French for French channels. Follow the channel brief language, not the user's prompt language. |
| "I'll skip the lint, the draft looks clean" | Always lint. Prose issues are invisible until checked. |
| "I'll mark it as posted before the user confirms" | Only the user decides when a message is posted. |

## Checklist

- [ ] `meetup-announce-start` called and JSON parsed
- [ ] Current **Window** identified (Early or Last)
- [ ] Pending **Messages** listed in order
- [ ] Each **Draft** written one at a time
- [ ] Each **Draft** linted with `prose-lint --profile meetup-announce`
- [ ] Each **Draft** approved by user before moving on
- [ ] `state.json` updated when user confirms posting
- [ ] **Topic-relevant** channel confirmed with user
- [ ] Thread replies flagged as manual-post-only
