---
name: skill-writer
description: Use when creating or updating skills.
---

# Skill Writer

## Overview

Creates and updates skills that make agents follow a process.

Skills are tracked inside the git root at `tools/ai/claude/config/skills/<name>/SKILL.md`.

## Core Workflow

### Step 1 — GRILL - Understand the goal

**Goal:** Reach shared understanding of what the skill should enforce.

**Exit criterion:** You can answer: what behavior should the agent follow, and in what situations?

Use the `/grill-me` skill to ask one question at a time, about *what* the skill
should enforce (not how to encode it).

---

### Step 2 — WRITE — Create or update the skill

**Goal:** Produce a skill file that captures the agreed behavior.

**Exit criterion:** Skill file written at the canonical location.

Read `references/skill-template.md`.
Create or update the skill file at the canonical location: `tools/ai/claude/config/skills/<name>/SKILL.md`.

---

### Step 3 — DONE

Skill is written.
Let the user commit.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "`~/.claude/skills/<name>/SKILL.md` is where the skill lives, I'll edit it there" | That path is a symlink to the main branch, not the current worktree. Edit inside the git root. |

## Checklist

- [ ] User confirmed the skill captures their intent
- [ ] Skill file at correct location (`tools/ai/claude/config/skills/<name>/SKILL.md`)
- [ ] Skill structure matches `references/skill-template.md` (Goal + Exit criterion per step, Checklist, Rationalizations)
