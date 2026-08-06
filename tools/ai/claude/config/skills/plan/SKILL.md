---
name: plan
description: Use when planning a feature end-to-end — explores codebase, writes PRD, breaks into vertical-slice issues, commits.
---

# Plan

## Overview

Understand the problem, explore the codebase, write a PRD, break it into vertical-slice issues, and commit the plan artifacts.

---

## Step 1 — Understand

Understand the problem, explore the codebase, sketch the modules.

Read [01-understand.md](./references/01-understand.md) and follow all sub-steps.

---

## Step 2 — Write PRD

Write a PRD to crystallize the problem, the goal, the user stories.

Read [02-prd.md](./references/02-prd.md) and follow all sub-steps.

---

## Step 3 — Write issues

Split the work into vertical slices, build the dependency graph, and write them on disk.

Read [03-issues.md](./references/03-issues.md) and follow all sub-steps.

---

## Step 4 — End the planning session

**Goal:** End the planning session and hand off to user.

**Exit criterion:** user told to run ralph, `plan-end` called,

1. Tell the user to run `ralph` to begin implementation.
2. Run `plan-end <planDir>` — it stages all plan files, commits and quit claude

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I know this codebase, no need to explore" | Domain terms may have changed. Explore first. |
| "The modules are obvious, no need to check with the user" | Module scope and test scope are separate decisions. Confirm both. |
| "I will write the PRD in the current repo" | Always use `plan-start` — it handles worktree creation. |
| "I'll call git-worktree-create myself" | Always use `plan-start` — it handles worktree creation. |
| "These features belong together, I'll do them all at once" | Tracer bullets end-to-end. Thin verticals, not fat horizontal slices. |

## Checklist

- [ ] Step 1 checklist complete (see [01-understand.md](./references/01-understand.md))
- [ ] Step 2 checklist complete (see [02-prd.md](./references/02-prd.md))
- [ ] Step 3 checklist complete (see [03-issues.md](./references/03-issues.md))
- [ ] User gave permission to commit
- [ ] `plan-end <planDir>` called
- [ ] User told to run `/ralph <planDir>`
