# Write issues

Split the PRD into independently-grabbable vertical slices and persist them to disk.

1. Draft vertical slices — thin tracer bullets through all layers
2. Confirm slices with user — validate granularity and order
3. Write issues, state, and guidance — persist to `<planDir>`
4. Write `COMMIT_HINT.md` — describe goal and scope

---

## Draft vertical slices

**Goal:** Break the PRD into tracer-bullet issues.

**Exit criterion:** Slices drafted, each a thin vertical through all layers.

Break the plan into **tracer bullet** issues. Each issue is a thin vertical
slice that cuts through ALL integration layers end-to-end, NOT a horizontal
slice of one layer.

Slices may be 'HITL' or 'AFK'. HITL slices require human interaction (architectural
decision, design review). AFK slices can be implemented and merged without human
interaction. Prefer AFK over HITL where possible.

- Each slice delivers a narrow but COMPLETE path through every layer
- A completed slice is demoable or verifiable on its own
- Prefer many thin slices over few thick ones
- Do NOT re-explore the codebase — use prior context

For each issue, identify any **behavioral tests** or **scaffolding tests**
as defined in the `/tdd` skill.

---

## Confirm slices with user

**Goal:** Validate granularity and order.

**Exit criterion:** User approves the breakdown.

Present the proposed breakdown as a numbered list. For each slice, show:

- **Title**: short descriptive name
- **Type**: HITL / AFK
- **Blocked by**: which other slices (if any) must complete first
- **User stories covered**: which user stories this addresses (if the source material has them)
- **Behavioral Tests**: what behavior should be tested (skip if empty)
- **Scaffolding Tests**: what structural transformation should be tested (skip if empty)

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the dependency relationships correct?
- Should any slices be merged or split further?
- Are the correct slices marked as HITL and AFK?

If the user suggests changes, present the new breakdown again. Only move to
writing issue files once the user approves the breakdown.

---

## Write issues, state, and guidance

**Goal:** Persist issues and metadata to disk.

**Exit criterion:** All issue files, `state.json`, and `GUIDANCE.md` created in `<planDir>`.

- Create one issue per slice following [the issue template](./templates/issues-XX-slug.template.md)
- Create a [state.json](./templates/state-json.template.md) containing all issues and their dependencies
- Create a [GUIDANCE.md](./templates/GUIDANCE.template.md) to guide subsequent agents

---

## Write COMMIT_HINT.md

Write `COMMIT_HINT.md` to `<planDir>/COMMIT_HINT.md`.
Load the **commit hint** reference from the `/ralph` skill for format and rules.
Derive Goal from the PRD's Problem Statement.
Suggested type is `plan(<slug>)` where slug is the plan directory name.

## Checklist

- [ ] Vertical slices drafted — each is a tracer bullet through all layers
- [ ] User confirmed: granularity feels right
- [ ] User confirmed: dependency order is correct
- [ ] issues/XX-slug.md written for each approved slice
- [ ] Each issue contains "What to build" and "Acceptance criteria"
- [ ] Each issue has considered its Behavioral Tests
- [ ] Each issue has considered its Scaffolding Tests
- [ ] `state.json` written — all issues with `done: false`
- [ ] `GUIDANCE.md` written — Guidance + Discoveries sections present
- [ ] `COMMIT_HINT.md` written with `plan(<slug>)` type
