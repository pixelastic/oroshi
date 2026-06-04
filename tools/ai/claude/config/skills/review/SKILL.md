---
name: review
description: Use when the user wants to review a branch, a PR, work-in-progress changes, or asks to "review since X". Reviews changes along two axes — Standards (does the code follow this repo's documented coding standards?) and Spec (does the code match the originating issue/PRD?). Runs both axes as parallel sub-agents and reports them side by side.
---

# Review

## Overview

Two-axis review of the diff between `HEAD` and a fixed point. Both axes run as parallel sub-agents so they don't pollute each other's context, then this skill aggregates their findings.

## Core Workflow

### Step 1 — Determine args

**Goal:** Resolve named params into `review-diff` args and spec path.

**Exit criterion:** `ref:` and `spec:` resolved; ready to pass to sub-agents.


| Param | Meaning |
|---|---|
| `ref:<ref>` | Diff base; passed to `review-diff` |
| `spec:<path>` | Path to the spec file (issue or PRD); passed to the Spec agent |


**`ref:` values:**

| Value | `review-diff` args |
|---|---|
| `ref:dirty` | All dirty files in repo |
| `ref:worktree` | All changed files since start of worktree |
| `ref:<branch>` | All changed files since start of `<branch>` |
| `ref:<commit>` | All changed files in `<commit>` |
| `ref:<start>..<end>` | All changed files between `<start>` and `<end>` |


If `spec:` or `ref:` is absent and cannot be inferred from context, ask the user — do not silently infer.

### Step 2 — Spawn sub-agents

**Goal:** Run Standards and Spec reviews in parallel without polluting each other's context.

**Exit criterion:** Both sub-agents have returned their reports.

Send a single message with two `Agent` tool calls. Use the `general-purpose` subagent for both.

- **Standards agent:** read `references/standards-agent.md` for the full brief;
- **Spec agent:** read `references/specs-agent.md` for the full brief;

### Step 3 — Aggregate

**Goal:** Present both reports side by side without merging or reranking.

**Exit criterion:** Both reports displayed; one-line summary given.

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings — the two axes are deliberately separate.

End with a one-line summary: total findings per axis, and the worst single issue (if any) flagged.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "The two findings overlap, I'll merge them into one report" | Merged reports hide which axis a finding belongs to. Keep them separate. |
| "Spec findings are minor, not worth reporting" | Spec drift compounds. Report everything; let the user dismiss. |

## Checklist

- [ ] Args determined from user intent
- [ ] Both sub-agents spawned in a single parallel message
- [ ] Each sub-agent ran `review-diff` itself — no diff pasted inline
- [ ] Reports presented under separate `## Standards` and `## Spec` headings
- [ ] One-line summary at the end
