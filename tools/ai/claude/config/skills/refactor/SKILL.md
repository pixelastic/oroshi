---
name: refactor
description: Use when user needs to systematically refactor a large or organically-grown codebase — not for quick one-off refactors. Produces a wave-based plan of issues (reduce → rewrite → restructure). Argument selects the wave.
argument-hint: [reduce|rewrite|restructure]
effort: high
---

# Refactor

## Overview

Systematic wave-based refactoring that produces a plan of issues, not direct code changes.
Constraint: zero behavior change, only refactoring, tests stay green before and after.

Three waves, run sequentially:
1. **Reduce** — dead code, duplication, naming
2. **Rewrite** — complex methods, coupling, responsibilities
3. **Restructure** — module boundaries, dependency flow, layering

Each wave produces issues, not patches.

---

## Core Workflow

### Step 1 — Parse wave

**Goal:** Identify which wave to run.

**Exit criterion:** Wave determined, `currentWave` and `nextWave` known.

Extract the wave from `$ARGUMENTS`: if it contains `reduce`, `rewrite`, or `restructure`, use that word. Otherwise default to `reduce`.
Run `refactor-start <wave>` and parse the JSON output. It returns `currentWave` and `nextWave`.

---

### Step 2 — Analyze

**Goal:** Scan the codebase for refactoring opportunities matching `currentWave`.

**Exit criterion:** Analysis complete, findings collected.

1. Read `references/<currentWave>.md` for the analysis categories.
2. Scan the code in the current directory for issues matching `currentWave`'s categories.

---

### Step 3 — Catalog bugs

**Goal:** Record any bugs found during analysis without fixing them.

**Exit criterion:** Bugs appended to GUIDANCE.md, or skipped if none found.

If you spotted bugs during analysis, append them to the plan's GUIDANCE.md under `## Bugs found`.
Do **not** fix them — Two Hats principle: refactoring hat and bug-fixing hat are separate.

---

### Step 4 — Plan

**Goal:** Produce issue files and update state.json.

**Exit criterion:** Issues written to disk, state.json updated.

**If `currentWave` is `reduce`:**
create a new plan by invoking the `/plan` skill, passing findings as context for issue creation.

**If `currentWave` is `rewrite` or `restructure`:**
update the existing plan previously created by `/plan`.
Read the plan's `state.json`, find the highest issue `id`, create new issue
files starting from the next id, and append entries to `state.json`.

For each finding, apply the test gate:
- If tests exist for the affected code → create the refactoring issue.
- If no tests exist → create a "Write characterization tests for X" issue first,
then the refactoring issue immediately after it (with `blocked_by` dependency).
Keep them paired.

Write each refactoring issue using [references/refactoring-issue.template.md](references/refactoring-issue.template.md).

---

### Step 5 — Checkpoint

**Goal:** Add a HITL checkpoint issue at the end of this wave's issues.

**Exit criterion:** Checkpoint issue written and appended to state.json.

Read the checkpoint template for `currentWave`: `references/checkpoint-<currentWave>.template.md`

Write the checkpoint as an issue file, add it to state.json after this wave's issues.
Replace `<next-wave>` in the template with `nextWave` from Step 1.

---

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "I'll fix this bug while refactoring" | Bugs are cataloged, never fixed during refactoring. Two Hats principle. |
| "This code doesn't need tests, the change is trivial" | Every refactoring needs a test gate. Write characterization tests first. |

## Checklist

- [ ] `refactor-start` called, `currentWave` and `nextWave` parsed
- [ ] Reference file for `currentWave` read
- [ ] Code analyzed using `currentWave`'s categories
- [ ] Bugs cataloged in GUIDANCE.md `## Bugs found` (not fixed)
- [ ] Test gate applied per finding (characterization test issue paired before refactoring issue)
- [ ] Plan created (reduce) or issues appended (rewrite/restructure)
- [ ] Every refactoring issue includes the refactoring constraint block
- [ ] Checkpoint issue added using `checkpoint-<currentWave>.template.md`
