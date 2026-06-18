---
name: review-slide
description: Use when the user wants to review a slide screenshot for design quality. Triggers on "review slide", "slide review", "review this slide". Evaluates the slide against design principles across 4 axes (Grouping, Readability, Colors, Spacing) using parallel sub-agents.
---

# Review Slide

## Overview

Visual design review of a slide screenshot. Runs each axis as a parallel sub-agent, then aggregates.

## Core Workflow

### Step 1 — Determine the image

**Goal:** Resolve the screenshot path.

**Exit criterion:** Valid image path in hand.

The user passes the image path as the skill argument. If no argument provided, ask the user for the path.

Verify the file exists before proceeding.

### Step 2 — Spawn sub-agents

**Goal:** Run design axes in parallel without polluting each other's context.

**Exit criterion:** All sub-agents have returned their reports.

Send a single message with 4 Agent tool calls. Use `general-purpose` subagent type for each.

Each agent prompt must include:
1. Read the screenshot at `<image-path>` using the Read tool
2. Read its reference file at the path given below
3. Evaluate the slide against the principles in the reference
4. Return findings in the format specified by the reference

| Agent | Reference file |
|---|---|
| Spacing | `references/spacing.md` |
| Readability | `references/readability.md` |
| Grouping | `references/grouping.md` |
| Colors | `references/colors.md` |

### Step 3 — Aggregate

**Goal:** Present reports concisely, suppressing noise.

**Exit criterion:** All reports displayed; summary given.

Present each report under its own heading, in this order: `## Spacing`, `## Readability`, `## Grouping`, `## Colors`.

**Nitpick suppression:** Within each axis, if there are any `improvement` findings, hide all `nitpick` findings for that axis. Only show nitpicks when an axis has zero improvements.

Do **not** merge or rerank findings — the axes are deliberately separate.

End with a one-line summary: per-axis improvement counts + total. If nitpicks were suppressed, append "(N nitpicks hidden)".

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The findings overlap, I'll merge them into one report" | Merged reports hide which axis a finding belongs to. Keep them separate. |
| "I can evaluate all axes myself without sub-agents" | Each axis needs isolated context. Use the agents. |
| "Only one group has findings, skip the summary" | Always show the summary — it confirms all axes were checked. |

## Checklist

- [ ] Image path resolved and file exists
- [ ] Sub-agents spawned in a single parallel message
- [ ] Each sub-agent read the screenshot via Read tool
- [ ] Reports presented under separate headings
- [ ] One-line summary with per-group finding counts and worst severity
