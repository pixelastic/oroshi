---
name: refactor
description: Use when user needs to systematically refactor a large or organically-grown codebase — not for quick one-off refactors. Produces a wave-based plan of issues (reduce → rewrite → restructure). Argument selects the wave.
argument-hint: [reduce|rewrite|restructure]
effort: high
---

# Refactor

## Overview

Systematic wave-based refactoring that produces a plan of issues, not direct
code changes. Constraint: zero behavior change, only refactoring, tests stay
green before and after.

Three waves, run sequentially:

1. **Reduce** — dead code, duplication, naming
2. **Rewrite** — complex methods, coupling, responsibilities
3. **Restructure** — module boundaries, dependency flow, layering

---

## Core Workflow

### Step 1 — Parse wave

**Goal:** Identify which wave to run.

**Exit criterion:** Wave determined, `currentWave` and `nextWave` known.

Extract the wave from `$ARGUMENTS`: if it contains `reduce`, `rewrite`, or
`restructure`, use that word. Otherwise default to `reduce`. Run
`refactor-start <wave>` and parse the JSON output. It returns `currentWave` and
`nextWave`.

---

### Step 2 — Analyze

**Goal:** Scan the codebase for refactoring opportunities matching
`currentWave`.

**Exit criterion:** Analysis complete, findings collected.

1. Read `references/<currentWave>.md` for the analysis categories.
2. Scan the code under the current working directory for issues matching
   `currentWave`'s categories.
3. If a test of the scanned code fails, stop. Tell the user to fix the tests
   first.
4. If the `currentWave` is `rewrite` or `restructure` and no plan exists, stop.
   Tell the user to run the earlier waves first.

---

### Step 3 — Catalog bugs

**Goal:** Record any bugs found during analysis without fixing them.

**Exit criterion:** Bugs appended to the plan's GUIDANCE.md, or skipped if none
found.

If you spotted bugs during analysis, append them to the GUIDANCE.md of the plan
(run `plan-directory` to find it) under `## Bugs found`. In the `reduce` wave,
no plan exists yet: hold the bugs, then append them once Step 5 creates the
plan. Do **not** fix them — Two Hats principle: refactoring hat and bug-fixing
hat are separate.

---

### Step 4 — Present & Align

**Goal:** Reach shared understanding with the user on which findings to act on.

**Exit criterion:** User approved the set of findings to turn into issues.

1. Present findings as a table: file, line range, category (one of the
   categories of `references/<currentWave>.md`), description, confidence
   (high/medium/low).
2. Present cataloged bugs separately.
3. Use `/grill-me` to discuss findings with the user — which to keep, drop,
   merge, or reframe.
4. Only proceed to Step 5 once the user approves the final set of findings.
5. If the analysis found no finding, or the user rejected every finding, stop.
   Create no issue. Tell the user to run `/refactor <nextWave>`.

---

### Step 5 — Plan

**Goal:** Produce issue files and update state.json.

**Exit criterion:** Issues written to disk, state.json updated.

**If `currentWave` is `reduce`:** create a new plan by invoking the `/plan`
skill, passing approved findings as context for issue creation.

**If `currentWave` is `rewrite` or `restructure`:** update the existing plan
previously created by `/plan` (run `plan-directory` to find it). Read the plan's
`state.json`, find the highest issue `id` in `.issues[]`, create new issue files
starting from the next id, and append entries to `.issues[]`. Use the same
format as the existing issues created by `/plan`, for files and entries alike.

For each finding, apply the test gate:

- If the existing tests exercise every guard and error path of the affected code
  (judge by reading the tests) → create the refactoring issue.
- If no tests exist, or they cover only the nominal case → create a "Write
  characterization tests for X" issue first (guards and error paths included),
  then the refactoring issue with the next id and a `blocked_by` dependency on
  the characterization issue. Never drop or reorder one without the other.

Write each refactoring issue using
[references/refactoring-issue.template.md](references/refactoring-issue.template.md).
Keep its `## Impact` section, heading included, for `restructure` issues only.
Delete it from the issues of the other waves.

Write each characterization issue with the same template, and replace its
`## Refactoring constraint` section with: "Write tests that pass on the current
code. Do not change the source code. No TDD cycle."

---

### Step 6 — Checkpoint

**Goal:** Add a HITL checkpoint issue at the end of this wave's issues.

**Exit criterion:** Checkpoint issue written and appended to state.json.

Read the checkpoint template for `currentWave`:
`references/checkpoint-<currentWave>.template.md`

Write the checkpoint as an issue file, add it to `.issues[]` in state.json after
this wave's issues. Replace `<next-wave>` in the template with `nextWave` from
Step 1.

---

## Common Rationalizations

| Rationalization                                       | Reality                                          |
| ----------------------------------------------------- | ------------------------------------------------ |
| "I'll fix this bug while refactoring"                 | See Step 3.                                      |
| "This code doesn't need tests, the change is trivial" | Every finding goes through the Step 5 test gate. |
| "Findings are clear, no need to check with user"      | Step 4 approval is mandatory.                    |

## Checklist

- [ ] `refactor-start` called, `currentWave` and `nextWave` parsed
- [ ] Reference file for `currentWave` read
- [ ] Code analyzed using `currentWave`'s categories
- [ ] Bugs cataloged, not fixed (Step 3)
- [ ] User approved the findings (Step 4)
- [ ] Test gate applied per finding (Step 5)
- [ ] Plan created (reduce) or issues appended (rewrite/restructure)
- [ ] Every refactoring issue keeps the `## Refactoring constraint` section of
      the template
- [ ] Checkpoint issue added using `checkpoint-<currentWave>.template.md`
