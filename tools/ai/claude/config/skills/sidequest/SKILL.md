---
name: sidequest
description: Use when user says "sidequest" or "handoff" — compact conversation context into a document for a fresh agent to pick up.
---

# Sidequest

## Overview

Compact the current conversation into a sidequest document; copy the launch command to the clipboard.

---

## Core Workflow

### Step 1 — Derive slug

Derive a 3-5 word kebab-case slug from the conversation content

### Step 2 — Write document


- Compact and focus the conversation on the aspect the user wants to tackle.
- Give enough context so a new agent can pick up from it
- Reference existing artifacts (plans, GLOSSARY, commits, diffs) by path — don't duplicate.
- Suggest skills the next session should use, if any.
- Write file to `/tmp/oroshi/claude/sidequests/<slug>.md`.

### Step 3 — Finalize

Run `sidequest-end <filepath>`.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll copy content from the PRD/plan, it's easier" | Don't duplicate — reference by path. Duplication goes stale. |
| "I don't need to call sidequest-end, the file is enough" | Without `sidequest-end`, the launch command never reaches the clipboard. |

---

## Checklist

- [ ] Slug derived (3-5 words, kebab-case)
- [ ] File at `/tmp/oroshi/claude/sidequests/<slug>.md`
- [ ] Artifacts referenced by path, not duplicated
- [ ] Skills suggested for next session (if applicable)
- [ ] `sidequest-end <filepath>` run — launch command on clipboard
