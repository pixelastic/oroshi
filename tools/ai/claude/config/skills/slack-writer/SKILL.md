---
name: slack-writer
description: Use when user needs to write a Slack message — replying to a colleague, announcing an event, or sharing information.
---

# Slack Writer

## Overview

Transform a brain dump (often speech-to-text) into a clear, concise Slack message. Two modes: **reply** (answering a colleague) and **announce** (posting to a channel). Same principles, different emphasis.

## Core Workflow

### Step 1 — Setup

**Goal:** Initialize a draft session.

**Exit criterion:** `draftPath` obtained.

Run `slack-writer-start` and parse the JSON output to get the `draftPath`.

### Step 2 — Assess context

**Goal:** Determine if you have enough information to write the message.

**Exit criterion:** You have all critical info, OR you've asked your clarifying questions.

Read the user's input (brain dump, file, conversation context). Identify the mode:
- **Reply** — answering a colleague's question or sharing info in DM/thread
- **Announce** — posting an event, project, or news to a channel

If critical info is missing (who's the audience, what's the key message, a date for an event), ask 1-2 targeted questions. If the input is complete, move directly to Step 3.

Bias: ask rather than guess. A wrong draft wastes more time than a quick question.

### Step 3 — Language

**Goal:** Determine output language.

**Exit criterion:** Language stated (e.g., "Language: English").

Default to English.
Switch only on explicit user request.
Input language is not a valid signal to change output language.

### Step 4 — Write draft

**Goal:** Produce a single Slack-ready message in the chosen language, saved to `draftPath`.

**Exit criterion:** Draft file written to disk.

Apply these principles, by priority:

1. **Respect their attention.** The reader's time > your thoroughness. Every word must earn its place. No repetitions — say it once. Stop writing when the point is made.

2. **Important thing first.** Inverted pyramid: lead with the answer or key info, never build up to a conclusion. If the reader stops after the first sentence, they have the essential. The more they read, the more detail they get. If the answer is yes or no, say it first, then explain.

3. **Scannable.** People scan, they don't read. Structure should guide the eye so the reader gets the gist without reading every word.
Formatting allowlist: bullets, numbered lists, `code` backticks. Nothing else — no bold, no links, no headers. Let whitespace breathe.

4. **Complete in one message.** Don't make them pull information out of you — give the answer, the why, and a reference if useful, all upfront. But stay open: inform, don't close the conversation.

5. **Sound human.** Write like a colleague, not a report. Softeners are fine ("I think", "not sure", "..."). Light emoji is OK when it takes the edge off. Avoid categorical phrasing that sounds robotic ("I have zero context." → "No idea what these are about...").

Write the draft to `draftPath` using the **Create** tool.

### Step 5 — Lint

**Goal:** Ensure the draft passes prose linting.

**Exit criterion:** Zero errors. Warnings and suggestions addressed as best effort.

Run `prose-lint <draftPath>` to get a JSON array of violations with `line`, `rule`, `severity`, `match`, and `message` fields.

Loop: fix `draftPath` (using the Edit tool), re-lint. Repeat until zero errors remain. Warnings may stay if justified.

### Step 6 — Finalize

**Goal:** Display the final message.

**Exit criterion:** Message displayed and `slack-writer-end` called.

1. Run `slack-writer-end <draftPath>`
2. Display the message (read `draftPath` and show it).

If the user requests changes, edit the draft, then re-run Steps 5-6.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user prompted in French so I'll write in French" | Default to English. French only if explicitly requested. |

## Checklist

- [ ] `<draftPath>` obtained from `slack-writer-start`
- [ ] Important info is in the first sentence
- [ ] No repeated information
- [ ] Language verified (English unless explicitly requested otherwise)
- [ ] `prose-lint` returns zero errors
- [ ] `slack-writer-end` called with `<draftPath>`
