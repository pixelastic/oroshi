---
name: tdd
description: Used when user wants to build features or fix bugs using TDD or red-green-refactor loop.
---

# Test-Driven Development

## Overview

Build features and fix bugs using the red-green-refactor loop: write a failing test first, write minimal code to pass it, then refactor.

Use **Behavioral** tests for behavioral testing, and **Scaffolding** tests for structural architecture.

Apply the London School of TDD for mocking. Each unit is tested in isolation by mocking its immediate collaborators.


## Core Workflow

### Step 1 — Plan

**Goal:** Agree on interface, behaviors to test, and test strategy before writing any code.

**Exit criterion:** User has approved the plan and test strategy is declared (scaffold/behavioral and what to mock).

When exploring the codebase, use the project's domain glossary so that test names and interface vocabulary match the project's language.

Apply the pivot question for each test:
> "If I rewrote the internals from scratch while keeping the same public API, would this test still pass?"

- **YES** → Use [behavioral-tests.md](references/behavioral-tests.md)
- **NO** → Use [scaffolding-tests.md](references/scaffolding-tests.md)

Ask yourself "What should the public interface look like? Which behaviors are most important to test?"

**You can't test everything.**
Confirm with the user exactly which behaviors matter most.
Focus testing effort on critical paths and complex logic, not every possible edge case.

- [ ] Confirm with user what interface changes are needed
- [ ] List the behaviors to test (prioritize)
- [ ] For each behavior: list behavioral tests needed (public API, survives any rewrite)
- [ ] For each behavior: list scaffolding tests needed (implementation detail, ephemeral)
- [ ] Confirm with user what to mock
- [ ] Identify opportunities for [deep modules](references/deep-modules.md) (small interface, deep implementation)
- [ ] Get user approval on the plan

### Step 2 — Tracer Bullet

**Goal:** Prove the test infrastructure works with one failing test and one minimal implementation.

**Exit criterion:** One test is RED, then GREEN — the path works end-to-end.

Write ONE test that confirms ONE thing about the system:

```
RED:   Write test for first behavior → test fails
GREEN: Write minimal code to pass → test passes
```

This is your tracer bullet — proves the path works end-to-end.

**DO NOT write all tests first, then all implementation.**
This is "horizontal slicing" — treating RED as "write all tests" and GREEN as "write all code."

This produces **crap tests**:

- Tests written in bulk test _imagined_ behavior, not _actual_ behavior
- You end up testing the _shape_ of things (data structures, function signatures) rather than user-facing behavior
- Tests become insensitive to real changes — they pass when behavior breaks, fail when behavior is fine
- You outrun your headlights, committing to test structure before understanding the implementation

**Correct approach**: Vertical slices via tracer bullets. One test → one implementation → repeat.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
  ...
```

### Step 3 — Incremental Loop

**Goal:** Cover all planned behaviors one test at a time.

**Exit criterion:** All planned behaviors have a passing test, no speculative features added.

For each remaining behavior:

```
RED:   Write next test → fails
GREEN: Minimal code to pass → passes
```

Rules:

- One test at a time
- Only enough code to pass current test
- Don't anticipate future tests
- Use dedicated skill (`zsh-writer`, `js-writer`, etc.) if it exists
- Test private helpers with complex logic
- Mock those helpers in callers that delegate to those helpers

### Step 4 — Refactor

**Goal:** Improve the design without changing behavior.

**Exit criterion:** No duplication, clean names, all tests still green.

After all tests pass, look for [refactor candidates](references/refactoring.md):

- [ ] Extract duplication
- [ ] Deepen modules (move complexity behind simple interfaces)
- [ ] Apply SOLID principles where natural
- [ ] Consider what new code reveals about existing code
- [ ] Run tests after each refactor step

**Never refactor while RED.** Get to GREEN first.

## Common Rationalizations

| Rationalization | Reality |
|---|---|
| "Private methods shouldn't be tested directly" | `private` controls API visibility, not testability. Complex logic deserves a test regardless of exposure. |
| "Mocking internal collaborators couples tests to implementation" | Mocking *immediate* collaborators is isolation, not coupling. Coupling is reaching *inside* your collaborator. |
| "Testing at the public interface is always enough" | No. Complex private helpers should also be tested.
| "I'll write the test after to go faster" | Tests-after prove nothing. Delete the code. Start with RED. |
| "I should write all tests first, then implement" | That's horizontal slicing. It produces tests of imagined behavior. Do vertical tracer bullets instead. |

## Checklist

- [ ] Test strategy declared: scaffold/behavioral and what to mock
- [ ] Private helpers with complex logic have direct unit tests
- [ ] Callers mock their immediate collaborators, not two levels down
- [ ] Test describes behavior, not implementation
- [ ] Test would survive internal refactor
- [ ] Code is minimal for this test
- [ ] Code uses dedicated language skill if it exists (`zsh-writer`, `js-writer`, etc)
- [ ] No speculative features added
