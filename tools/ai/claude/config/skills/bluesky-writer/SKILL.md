---
name: bluesky-writer
description: Use when user needs to write a Bluesky post or thread — announcing a release, sharing a link, reacting to news. Drafts, lints and waits for approval. Never publishes.
---

# Bluesky Writer

## Overview

Transform a brain dump (often speech-to-text) into a Bluesky post or thread. The
skill drafts, lints and waits for approval. It never publishes: after approval,
the user asks Claude to run `bluesky-post-create`.

## Core Workflow

### Step 1 — Setup

**Goal:** Initialize a draft session.

**Exit criterion:** `draftPath` obtained.

Run `bluesky-writer-start` and parse the JSON output to get the `draftPath`.

### Step 2 — Assess context

**Goal:** Determine if you have enough information to write the post.

**Exit criterion:** You have all critical info, OR you've asked your clarifying
questions.

Read the user's input (brain dump, file, conversation context). If critical info
is missing (the key message, the link, who it is for), ask one or two targeted
questions. If the input is complete, move directly to Step 3.

Bias: ask rather than guess. A wrong draft wastes more time than a quick
question.

### Step 3 — Language

**Goal:** Determine output language.

**Exit criterion:** Language stated (e.g., "Language: English").

Default to English. Switch to French only on explicit user request. Input
language is not a valid signal to change output language.

### Step 4 — Write draft

**Goal:** Produce a post, or a thread, in the chosen language, saved to
`draftPath`.

**Exit criterion:** Draft file written to disk.

Follow the `/prose-writer` skill, with these principles by priority:

1. **Important thing first.** Inverted pyramid: lead with the news or the point.
   If the reader stops after the first sentence, they have the essential.
2. **Respect their attention.** Every word earns its place. Say it once. Stop
   when the point is made.
3. **Sound human.** Write like a person talking to peers, not a brand. Softeners
   are fine ("I think", "not sure"). No marketing phrasing, no hype.
4. **Plain text only.** Bluesky does not render Markdown: no bold, no headers.
   Links, `#hashtags` (two at most) and `@mentions` are allowed. Images use
   `![alt](path)`, with alt text.
5. **One idea per post.** If the content needs more than one post, write a
   thread.

A thread is one draft. Separate the posts with a line of exactly three dashes
(`---`).

Do not count characters yourself. The linter checks the length.

Write the draft to `draftPath` using the **Create** tool.

### Step 5 — Lint

**Goal:** Ensure the draft passes both linters.

**Exit criterion:** Zero errors from both linters. Warnings addressed as best
effort.

Run both, from the same draft:

- `prose-lint --profile bluesky-writer <draftPath>` — voice and formatting.
- `bluesky-post-lint --text-file <draftPath>` — length, images, alt text. Add
  `--thread` when the draft has several posts.

Loop: fix `draftPath` (using the Edit tool), re-lint both. Repeat until zero
errors remain. Warnings may stay if justified.

### Step 6 — Finalize

**Goal:** Display the draft and get user approval.

**Exit criterion:** User approves the draft and `bluesky-writer-tick` called.

1. Run `bluesky-writer-tick <draftPath>`
2. Display the draft (read `draftPath` and show it).
3. Ask the user: approve or request edits.
   - If edits requested → loop back to Step 4 (Write draft).
   - If approved → skill ends. Do not publish. The user asks for it with
     `bluesky-post-create`.

## Common Rationalizations

| Rationalization                                       | Reality                                                  |
| ----------------------------------------------------- | -------------------------------------------------------- |
| "The user prompted in French so I'll write in French" | Default to English. French only if explicitly requested. |
| "The user approved, so I'll publish it now"           | Never publish. The user asks for it in a new request.    |
| "A little bold makes the key word stand out"          | Bluesky shows the asterisks. Plain text only.            |

## Checklist

- [ ] `<draftPath>` obtained from `bluesky-writer-start`
- [ ] Important info is in the first sentence
- [ ] Language verified (English unless explicitly requested otherwise)
- [ ] Thread posts separated by `---`
- [ ] `prose-lint --profile bluesky-writer` returns zero errors
- [ ] `bluesky-post-lint` returns zero errors
- [ ] `bluesky-writer-tick` called with `<draftPath>`
- [ ] `bluesky-post-create` never called
