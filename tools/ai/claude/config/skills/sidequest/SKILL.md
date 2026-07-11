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

Collect both the slug and the target repo (if the user mentioned one):

- **Slug:** derive a kebab-case slug of at most 2 words from the conversation content
- **Repo (optional):** if the user mentioned a project name, normalize it to a project name and run `project-path <name>`. Use the returned path as `--repo-dir`. If `project-path` fails or the name is ambiguous, ask the user for clarification before proceeding.

### Step 2 — Write document

- Follow `references/template.md`.
- Copy **[VERBATIM]** sections word-for-word; fill in **[DYNAMIC]** sections from the conversation.
- Write file to `/tmp/oroshi/claude/sidequests/<slug>.md`.

### Step 3 — Finalize

Run `sidequest <filepath> [--repo-dir <path>]`, then output: "Sidequest created in tab `<slug>`".

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll copy content from the PRD/plan, it's easier" | Don't duplicate — reference by path. Duplication goes stale. |
| "I don't need to call sidequest, the file is enough" | Without `sidequest`, no Worktree or Kitty tab is created. |
| "I'll skip project-path and use the path I think I know" | project-path is the authoritative resolver — always call it. |

---

## Checklist

- [ ] Slug derived (at most 2 words, kebab-case)
- [ ] Repo resolved via `project-path` if user mentioned one; asked for clarification if resolution failed
- [ ] File at `/tmp/oroshi/claude/sidequests/<slug>.md`
- [ ] `## Agent Instructions` section is verbatim and first in the document
- [ ] Artifacts referenced by path, not duplicated
- [ ] Skills suggested for next session (if applicable)
- [ ] `sidequest <filepath> [--repo-dir <path>]` run — Worktree, Kitty tab, and Claude session created
- [ ] Output "Sidequest created in tab `<slug>`"
