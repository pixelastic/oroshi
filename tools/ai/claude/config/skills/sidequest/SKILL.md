---
name: sidequest
description: Use when user says "sidequest" or "handoff" — compact conversation context into a document for a fresh agent to pick up.
---

# Sidequest

## Overview

Compact a specific part of the current conversation into a sidequest document.
This will create a new Worktree, Kitty tab, and Claude session.

---

## Core Workflow

### Step 1 — Gather prerequisites

Collect both the slug and the target repo:

- **Slug:** derive a kebab-case slug of at most 2 words from the conversation content
- **Repo:** run `sidequest-start [<project-name>]` (pass the project name if the user mentioned one).
  - `status=ok` → use `projectPath` as `--repo-dir` for `sidequest`
  - `status=unknown` → `candidates` is a JSON array of `"projectName▮projectPath"` strings; pick the closest name (semantic match), confirm with user ("Did you mean `<name>`?"), then use its path

### Step 2 — Write document

- Follow `references/template.md`.
- Copy **[VERBATIM]** sections word-for-word; fill in **[DYNAMIC]** sections from the conversation.
- Write file to `/tmp/oroshi/claude/sidequests/<slug>.md`.

### Step 3 — Finalize

Run `sidequest-end <filepath> [--repo-dir <path>]`, then output: "Sidequest created in tab `<slug>`".

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll copy content from the PRD/plan, it's easier" | Don't duplicate — reference by path. Duplication goes stale. |
| "I don't need to call sidequest, the file is enough" | Without `sidequest`, no Worktree or Kitty tab is created. |

---

## Checklist

- [ ] Slug derived (at most 2 words, kebab-case)
- [ ] Repo resolved via `sidequest-start [<name>]`; handled `ok`/`unknown` response
- [ ] File at `/tmp/oroshi/claude/sidequests/<slug>.md`
- [ ] `## Agent Instructions` section is verbatim and first in the document
- [ ] Artifacts referenced by path, not duplicated
- [ ] Skills suggested for next session (if applicable)
- [ ] `sidequest-end <filepath> [--repo-dir <path>]` run — Worktree, Kitty tab, and Claude session created
- [ ] Output "Sidequest created in tab `<slug>`"
