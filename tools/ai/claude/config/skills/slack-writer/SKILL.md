---
name: slack-writer
description: Use when user needs to write a Slack message — replying to a colleague, announcing an event, or sharing information.
---

# Slack Writer

## Overview

Transform a brain dump (often speech-to-text) into a clear, concise Slack message. Two modes: **reply** (answering a colleague) and **announce** (posting to a channel). Same principles, different emphasis.

## Core Workflow

### Step 1 — Assess context

**Goal:** Determine if you have enough information to write the message.

**Exit criterion:** You have all critical info, OR you've asked your clarifying questions.

Read the user's input (brain dump, file, conversation context). Identify the mode:
- **Reply** — answering a colleague's question or sharing info in DM/thread
- **Announce** — posting an event, project, or news to a channel

If critical info is missing (who's the audience, what's the key message, a date for an event), ask 1-2 targeted questions. If the input is complete, move directly to Step 2.

Bias: ask rather than guess. A wrong draft wastes more time than a quick question.

### Step 2 — Write draft

**Goal:** Produce a single Slack-ready message in English (French only if explicitly requested).

**Exit criterion:** A message the user could post in Slack.

Apply these principles, by priority:

1. **Respect their attention.** The reader's time > your thoroughness. Every word must earn its place. No repetitions — say it once. Stop writing when the point is made.

2. **Important thing first.** Inverted pyramid: lead with the answer or key info, never build up to a conclusion. If the reader stops after the first sentence, they have the essential. The more they read, the more detail they get. If the answer is yes or no, say it first, then explain.

3. **Scannable.** People scan, they don't read. Structure should guide the eye so the reader gets the gist without reading every word. Use bullets for 2+ points. No wall of text. Use `code` for commands terms. Let whitespace breathe.

4. **Complete in one message.** Don't make them pull information out of you — give the answer, the why, and a reference if useful, all upfront. But stay open: inform, don't close the conversation.

### Step 3 — Lint

**Goal:** Ensure the draft passes prose linting.

**Exit criterion:** Zero errors. Warnings and suggestions addressed as best effort.

Pass the draft (without the code block fences) to `prose-lint`:

```bash
prose-lint "<draft>"
```

`prose-lint` outputs a JSON array of violations with `line`, `rule`, `severity`, `match`, and `message` fields.

Loop: fix errors, fix warnings and suggestions where possible, re-lint. Repeat until zero errors remain. Warnings may stay if justified.

### Step 4 — Present

**Goal:** Copy to clipboard and display the final draft.

**Exit criterion:** Draft in clipboard and displayed.

First, copy to clipboard:

```bash
echo "<draft>" | slack-writer-end
```

Then display the message.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The user prompted in French so I'll write in French" | Default English. French only if explicitly requested. |

## Checklist

- [ ] Important info is in the first sentence
- [ ] No repeated information
- [ ] Language is English unless French was explicitly requested
- [ ] `prose-lint` returns zero errors
- [ ] Message copied to clipboard via `slack-writer-end`
