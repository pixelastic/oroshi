---
name: commit-writer
description: Use when the user needs a git commit message for staged changes.
---

# Commit Writer

## Overview

Generate one commit message in Conventional Commits format. Output only the message — no explanations, no analysis, no code blocks.

## Core Workflow

### Step 1 — Identify the change

Goal: isolate the single most significant change in the diff.

Read the diff. If it touches multiple unrelated areas, pick ONE most significant change. Ignore the rest.

### Step 2 — Write the subject line

Goal: produce a subject line that stands alone.

Format: `type(scope): description`

Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore`

- Imperative mood, ≤72 characters
- Must stand alone — someone reading `git log` should understand the change without the diff

```
✓ feat(auth): add password reset via email link
✓ fix(api): prevent race condition on concurrent writes
✗ fix: stuff
✗ updated auth module to use JWT instead of sessions because sessions were causing issues with the new load balancer setup
```

### Step 3 — Write the body

Goal: state the concrete impact in plain prose.

**Skip the body** only when the change is purely mechanical with no context to add: typo fix, dependency version bump, branch merge, whitespace-only. If in doubt, write it.

2 sentences max. What problem is solved, what is now possible, what is prevented.

**Never enumerate.** "Replaces X with Y, letting Z" describes mechanism, not impact — rewrite as the outcome.

```
✓ Prevents GUI errors from polluting terminal output
✓ Replaces manual alias workarounds — hook rewriting now handles proxying automatically
✓ Removes retry hack made obsolete by the official API's built-in backoff
✓ Renames variable to reflect its actual scope, reducing future misread risk
✗ Deleted legacy auth.js
✗ Added lodash dependency
✗ Updated config file
```

### Step 4 — Output

Goal: emit the message and nothing else.

Plain text only. No attribution, no code blocks, no preamble, no explanation.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I should explain my choice" | Output the message. Nothing else. |
| "The body should cover all changes" | One impact. Ignore the rest. |
| "This is complex, the body needs to be thorough" | 2 sentences max. Always. |
| "A code block makes it clearer" | Code blocks break automation. Plain text only. |
| "The subject is self-explanatory, no body needed" | Only skip for purely mechanical changes (typo, version bump, merge). Everything else has a *why*. |

## Checklist

- [ ] Subject line is ≤72 chars, imperative, stands alone
- [ ] Body states one concrete impact (not mechanism, not enumeration)
- [ ] Output is plain text — no extras
