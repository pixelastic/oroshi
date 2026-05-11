---
name: commit-writer
description: Guides agents through writing git commit messages in Conventional Commits format. Use when the user needs a commit message for staged changes.
---

# Commit Writer

## Overview

Generate a single commit message. Output only the message — no explanations, no analysis, no code blocks.

## Core Process

**Format:** `type(scope): description`

**Types:** `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore`

**Subject line:** imperative, ≤72 characters. Must stand alone — someone searching `git log` should understand the change without reading the diff.

**Body:** State ONE concrete impact in 2 sentences max. What problem is solved, what is now possible, what is prevented. Omit if the subject is self-explanatory.

```
✓ Prevents GUI errors from polluting terminal output
✓ Allows users to regain access without admin intervention
✗ Better maintainability and readability
✗ Improves code organization
```

**Never enumerate.** One impact. Two sentences. Constructions like "Replaces X with Y, letting Z" or "Removes X so that Y" are still enumerations in disguise — they describe mechanism, not impact.

```
✗ Replaces manual alias workarounds with RTK hook-based rewriting,
  letting Claude use standard commands without knowing about aliases.
✓ Bash commands are now automatically proxied without per-project
  alias configuration.
```

**Multiple concerns:** If the diff touches unrelated areas, pick ONE most significant change. Ignore the rest.

**No attribution:** Never include "Generated with Claude Code", "Co-Authored-By: Claude", or 🤖.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I should explain my choice" | Output the message. Nothing else. |
| "The body should cover all the changes" | One impact. Ignore the rest. |
| "This is complex, the body needs to be thorough" | 2 sentences max. Always. |
| "A code block makes it clearer" | Code blocks break automation. Plain text only. |
