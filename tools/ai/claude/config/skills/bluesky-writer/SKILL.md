---
name: bluesky-writer
description: Use when user needs to write a Bluesky post or thread — announcing
a release, sharing a link, reacting to news. Drafts, lints, waits for approval,
then publishes only when the user confirms.
---

# Bluesky Writer

## Overview

Transform a brain dump into a Bluesky post or thread. The skill drafts, lints
and waits for approval. It publishes only after the user confirms they want it.

## Core Workflow

### Step 1 — Setup

**Goal:** Initialize a draft session.

**Exit criterion:** `draftPath` obtained.

Run `bluesky-writer-start` and parse the JSON output to get the `draftPath`.

### Step 2 — Assess context

**Goal:** Determine if you have enough information to write the post.

**Exit criterion:** You have all critical info.

Read the user's input (brain dump, file, conversation context). When announcing
an article, read it in full and build its URL from the blog's permalink scheme.
If critical info is missing (the key message, the link, who it is for), ask one
or two targeted questions. If the input is complete, move directly to Step 3.

Bias: ask rather than guess. A wrong draft wastes more time than a quick
question.

### Step 3 — Write draft

**Goal:** Produce a post, or a thread, saved to `draftPath`.

**Exit criterion:** Draft file written to disk.

Write a post in English. Use the `/prose-writer` skill as a base, then add these
principles:

1. **Something that really happened to you.** Anchor the post in a personal
   moment from the work: a struggle, a surprise, a relief. Use the first person.
   It does not have to be the first sentence, but it must be there.
2. **Make them want to read more.** Tease with the payoff, or with one concrete
   detail or figure, or with both. Never list the steps or the failed attempts.
   A figure is optional, and only worth it if it makes the reader curious.
3. **Emoji only for a mood.** Do not decorate every line.
4. **Plain text only.** Bluesky does not render Markdown: no bold, no headers.
   Links, `#hashtags` (two at most) and `@mentions` are allowed. Images use
   `![alt](path)`, with alt text.
5. **Short paragraphs.** Separate the hook, the teaser and the link with blank
   lines. Put the link last.
6. **One idea per post.** If the content needs more than one post, write a
   thread.

Read `references/templates.md`. Pick the template that fits the strongest angle
of the article, and vary the choice from one post to the next.

An invitation to reply is optional. Add one only when it fits the post.

A thread is one draft. Separate the posts with a line of exactly three dashes
(`---`).

Write the draft to `draftPath` using the **Create** tool.

### Step 4 — Lint

**Goal:** Ensure the draft passes the linter.

**Exit criterion:** Zero errors. Warnings addressed as best effort.

Run `bluesky-post-lint --text-file <draftPath>`. It checks voice, formatting,
length, images and alt text. Add `--thread` when the draft has several posts.

Loop: fix `draftPath` (using the Edit tool), re-lint. Repeat until zero errors
remain. Warnings may stay if justified.

### Step 5 — Finalize

**Goal:** Display the draft and learn what the user wants next.

**Exit criterion:** `bluesky-writer-tick` called, and the user chose between
editing and publishing.

1. Run `bluesky-writer-tick <draftPath>`
2. Display the draft (read `draftPath` and show it).
3. Ask the user: publish it, or keep editing.
   - If editing → loop back to Step 3 (Write draft).
   - If publishing → go to Step 6.

### Step 6 — Publish

**Goal:** Publish the approved draft.

**Exit criterion:** `bluesky-post-create` ran and the post URL is shown.

Enter this step only when the user chose to publish at the end of Step 5. Run
`bluesky-post-create --text-file <draftPath>`. Add `--thread` when the draft has
several posts. Show the URL it prints.

## Common Rationalizations

| Rationalization                                       | Reality                                               |
| ----------------------------------------------------- | ----------------------------------------------------- |
| "The user prompted in French so I'll write in French" | Always write in English, whatever the input language. |
| "The draft looks good, so I'll publish it now"        | Publish only after the user chose it in Step 5.       |
| "A little bold makes the key word stand out"          | Bluesky shows the asterisks. Plain text only.         |
| "Listing what I tried makes the post concrete"        | It spoils the article. Tease it, do not summarize it. |

## Checklist

- [ ] `<draftPath>` obtained from `bluesky-writer-start`
- [ ] `references/templates.md` read before writing
- [ ] The post holds something personal that really happened
- [ ] Paragraphs separated by blank lines
- [ ] The link comes last
- [ ] Every item of the `prose-writer` checklist is checked too
- [ ] Post written in English
- [ ] Thread posts separated by `---`
- [ ] `bluesky-post-lint` returns zero errors
- [ ] `bluesky-writer-tick` called with `<draftPath>`
- [ ] User chose to publish before `bluesky-post-create` ran
