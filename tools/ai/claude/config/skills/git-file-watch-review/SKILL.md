---
name: git-file-watch-review
description: Use when user says "review comments", "process review", or "/git-file-watch-review". Processes git-file-watch review comments — applies code changes or answers questions, then removes each processed comment.
---

# Git File Watch Review

## Overview

Process review comments left in git-file-watch. Each comment targets a file and
line — either requesting a code change or asking a question. Process them one by
one, removing each as it's handled so progress is visible in real time.

---

## Core Workflow

### Step 1 — Fetch comments

**Goal:** Load the current review comments.

**Exit criterion:** Comments parsed, or empty list detected.

Run `git-file-watch-review-start` to get the JSON array of comments.

Each comment has: `id`, `filepath`, `lineNumber`, `lineContent`, `review`.

If the array is empty, tell the user there are no comments to process and stop.

---

### Step 2 — Process each comment

**Goal:** Apply every comment.

**Exit criterion:** All comments processed and removed.

For each comment in the array:

1. **Read context** — read the file to understand the surrounding code.
2. **Interpret the comment:**
   - **Action request** (e.g. "rename this", "extract to function", "fix bug") → apply the code change.
   - **Question** (e.g. "why is this here?", "what does this do?") → answer it in a short message to the user.
3. **Remove the comment** — run `git-file-watch-review-end <id>` so it disappears from git-file-watch immediately.

Move to the next comment only after the current one is fully handled.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The comment is unclear, I'll skip it" | Ask the user for clarification instead of skipping. |

## Checklist

- [ ] `git-file-watch-review-start` called and JSON parsed
- [ ] Each comment's file read for context around `lineNumber`
- [ ] Action requests applied as code changes
- [ ] Questions answered to the user
- [ ] `git-file-watch-review-end <id>` called after each processed comment
- [ ] Empty comment list handled gracefully — told user and stopped
