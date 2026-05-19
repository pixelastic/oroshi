---
name: to-issues
description: Break a plan, spec, or PRD into independently-grabbable issues using tracer-bullet vertical slices. Use when user wants to convert a plan into issues, create implementation tickets, or break down work into issues.
---

# To Issues

## Overview

Break a plan into independently-grabbable issues using vertical slices (tracer bullets).

## Core Workflow

### Step 1 - Gather context

Work from whatever is already in the conversation context, as well as any
relevant `PRD.md` file.

### Step 2 — Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Issue titles and descriptions should use the project's domain glossary vocabulary, and respect ADRs in the area you're touching.

### Step 3 - Draft vertical slices

Break the plan into **tracer bullet** issues. Each issue is a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction, such as an architectural decision or a design review. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

<vertical-slice-rules>
- Each slice delivers a narrow but COMPLETE path through every layer (schema, API, UI, tests)
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
</vertical-slice-rules>

### Step 4 - Quiz the user

Present the proposed breakdown as a numbered list. For each slice, show:

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

### Step 5 - Store the issues

For each approved slice, create a [issue-XXX-slug.md](./references/issue-XXX-slug.md) file in the same directory as the PRD, following the given template.

Write a [prd.json](./references/prd-json.md) and
[progress.md](./references/progress-md.md) following the given templates, as
siblings of the `PRD.md` file.
These files will help future agent pick up work where a previous agent left off.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "These features belong together, I'll do them all at once" | We need tracer bullets end-to-end. Thin verticals, not fat horizontal slices |

## Checklist

- [ ] Context gathered — PRD or plan source identified
- [ ] Codebase explored — domain glossary and ADRs identified
- [ ] Vertical slices drafted — each is a tracer bullet through all layers
- [ ] User confirmed: granularity feels right (not too coarse / too fine)
- [ ] User confirmed: dependency order is correct
- [ ] issue-XXX-slug.md written for each approved slice (numbered in dependency order)
- [ ] each issue file contains a "What to build" blurb and "Acceptance criteria" list
- [ ] prd.json written — one entry per test case, all `passes: false`
- [ ] progress.md written — execution order + guidance sections present
