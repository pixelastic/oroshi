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

### Step 3 — Write the body

Goal: state the concrete impact in plain prose.

Skip the body only when the change is purely mechanical with no context to add: typo fix, dependency version bump, branch merge, whitespace-only. If in doubt, write it.

2 sentences max. What problem is solved, what is now possible, what is prevented.

Never enumerate. Describe the outcome, not the mechanism.

### Step 4 — Output

Goal: emit the message and nothing else.

Plain text only. No attribution, no code blocks, no preamble, no explanation.
