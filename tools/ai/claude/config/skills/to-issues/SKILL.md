---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues using tracer-bullet vertical slices. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

## Overview

Break a PRD into independently-grabbable issues using vertical slices (tracer bullets).

## Core Workflow

### Step 1 - Gather context

**Goal:** Know enough context to write detailed issues.

**Exit criterion:** PRD, codebase and glossary explored.

- Work from whatever is already in the conversation context.
- Read any relevant `PRD.md` file
- Explore the codebase to understand the current state of the code.
- Use project Glossary and Decisions.

### Step 2 - Draft vertical slices

**Goal:** Break plan into tracer bullet issues

Break the plan into **tracer bullet** issues. Each issue is a thin vertical
slice that cuts through ALL integration layers end-to-end, NOT a horizontal
slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an
architectural decision or a design review. AFK slices can be implemented and
merged without human interaction. Prefer AFK over HITL where possible.

- Each slice delivers a narrow but COMPLETE path through every layer
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones

### Step 3 - Confirm with the user

**Goal:** Confirm granularity and order with user

**Exit criterion:** User confirms the breakdown.

Present the proposed breakdown as a numbered list.
For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

Iterate until the user approves the breakdown.

### Step 4 - Write the issues

**Goal:** Store issues and their relationships on disk

**Exit criterion:** All issues `.md` files, `issues.json` and `progress.md` created

- Create all files in the same directory as the `PRD.md`
- Create one [issue-XX-slug.md](./references/issue-XX-slug.md) file per issue
- Create a [issues.json](./references/issues-json.md) containing all issues and their dependencies
- Create a [progress.md](./references/progress-md.md) to guide subsequent agents

These files will help future agent pick up work where a previous agent left off.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "These features belong together, I'll do them all at once" | We need tracer bullets end-to-end. Thin verticals, not fat horizontal slices |

## Checklist

- [ ] Context gathered — PRD identified
- [ ] Codebase explored — code, glossary and decisions identified
- [ ] Vertical slices drafted — each is a tracer bullet through all layers
- [ ] User confirmed: granularity feels right (not too coarse / too fine)
- [ ] User confirmed: dependency order is correct
- [ ] issue-XX-slug.md written for each approved slice
- [ ] each issue file contains a "What to build" blurb and "Acceptance criteria" list
- [ ] issues.json written and contains all issues and their dependencies
- [ ] all issues in issues.json have `passes: false`
- [ ] progress.md written — execution order + guidance sections present
