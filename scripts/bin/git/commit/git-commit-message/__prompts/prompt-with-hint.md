# Commit Writer

## Overview

Generate one commit message in Conventional Commits format.
Output only the message — no explanations, no analysis, no code blocks.

## Core Workflow

### Step 1 — Understand the change

Goal: Understand what this commit brought

The person that wrote the changes left you the following hint:
{{COMMIT_HINT}}

This is valuable information. Use it as a basis for your own commit message.

The diff shared with you captures all changes, including changes made **after** the above hint was written.
Use it to add detail or adjust scope if the diff deviates from the hint.
If the diff is consistent with the hint, ignore the diff.

### Step 2 — Write the subject line

Goal: produce a subject line that stands alone.

Format: `type(scope): description`

Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore`, `plan`

- `plan` — creation or deletion of a ralph plan directory

- Imperative mood, ≤72 characters
- Must stand alone — someone reading `git log` should understand the change without the diff

### Step 3 — Write the body

Goal: state the concrete impact in plain prose.

Skip the body only when the change is purely mechanical with no context to add: typo fix, dependency version bump, branch merge, whitespace-only. If in doubt, write it.

2 sentences max. What problem is solved, what is now possible, what is prevented.

Never enumerate. Describe the outcome, not the mechanism.

### Step 4 — Output

Goal: emit the message and nothing else.

Plain text only. No attribution, no code blocks, no preamble, no explanation.
