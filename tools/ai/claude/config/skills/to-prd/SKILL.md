---
name: to-prd
description: Turn the current conversation context into a PRD and publish it to the project issue tracker. Use when user wants to create a PRD from the current context.
---

# To PRD

## Overview

This skill takes the current conversation context and codebase understanding and produces a PRD. Do NOT interview the user — just synthesize what you already know.

## Core Workflow

### Step 1 — Understand the codebase

Explore the repo to understand the current state of the codebase, if you haven't already.
Use the project's domain glossary vocabulary throughout the PRD.

### Step 2 — Sketch out

Sketch out the major modules you will need to build or modify to complete the implementation.
Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations.
Check with the user which modules they want tests written for.

### Step 3 — Write the PRD.md

Run `prd-end <branchName>` via the **Bash tool**, and parse the JSON output.
Write the PRD to `<prdPath>`, following [the template](./references/prd-md.md).

### Step 4 — Stop

Ask the user if they're ready to move to /to-issues


---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I know this codebase, no need to explore" | Domain terms may have changed. Explore first. |
| "The modules are obvious, no need to check with the user" | Module scope and test scope are separate decisions. Confirm both. |
| "I will write the PRD in the current repo" | Always use `prd-end` — it handles worktree creation and dep install |
| "I'll call git-worktree-create myself" | Always use `prd-end` — it handles worktree creation and dep install |

## Checklist

- [ ] Codebase explored — domain glossary identified
- [ ] Deep modules identified — each has a simple, testable interface
- [ ] User confirmed module list matches intent
- [ ] User confirmed which modules get tests
- [ ] `prd-end <branchName>` called via Bash tool, JSON output parsed
- [ ] PRD.md written to `<prdPath>`
- [ ] PRD contains all 6 sections present (Problem, Solution, User Stories, Implementation Decisions, Testing Decisions, Out of Scope)
