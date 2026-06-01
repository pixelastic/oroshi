## Problem Statement

When running Ralph autonomously over many issues, agents write tests in two fundamentally different categories: tests that verify observable behavior (survive refactoring) and tests that verify a structural transformation happened (e.g. an old method is gone). Both are legitimate, but they have different lifetimes and different purposes. Today all tests land in `__tests__/` indiscriminately, creating long-term test debt: refactoring-verification tests break when internals change, mislead future readers, and erode trust in the test suite.

## Solution

Introduce a first-class concept of **scaffolding tests** — task-scoped verification scripts that prove an agent completed its work, stored as plan artifacts (`plans/<slug>/scaffold/issue-N.bats`), never committed to the production test suite. Contrast with **permanent tests** — behavioral specifications that test observable outputs through the public API and survive any internal rewrite.

The distinction is encoded at three levels:
- **TDD skill**: owns the definition, the pivot question, and the path convention (source of truth)
- **ToIssues skill**: declares intent per-issue via two optional fields (`scaffolding-test`, `permanent-test`) at planning time
- **Ralph skill**: reads those fields, can enrich/override with implementation context, and routes tests to the correct location

## User Stories

1. As a developer reviewing a test suite weeks after a sprint, I want all tests to test observable behavior, so that refactoring internals never breaks tests without a behavioral reason.
2. As an agent running Ralph, I want clear guidance on where to write scaffolding vs permanent tests, so that I never accidentally commit a grep-based test to `__tests__/`.
3. As a developer writing issues with ToIssues, I want to declare what each issue should verify (scaffolding, permanent, or both), so that the implementing agent has explicit intent to work from.
4. As an agent running Ralph, I want to be able to override the test-type declared at issue-creation time, so that implementation discoveries (e.g. existing permanent tests already cover the behavior) are reflected in what actually gets written.
5. As a developer archiving a completed plan, I want scaffolding tests colocated in the plan folder, so that deleting the plan removes them cleanly.
6. As an agent running TDD standalone (outside Ralph), I want to know the scaffolding vs permanent distinction, so that I apply it consistently regardless of orchestration.
7. As a developer running pre-commit, I want scaffolding tests to run if they were modified, so that broken scaffolding tests are caught before commit.
8. As an agent writing an issue in ToIssues, I want the issue template to have explicit `scaffolding-test` and `permanent-test` fields, so that I can express partial intent (one, the other, or both).

## Implementation Decisions

- **Pivot question** (owned by TDD): "If I rewrote the internals from scratch while keeping the same public API, would this test still pass?" YES → permanent. NO → scaffolding.
- **Path convention**: scaffolding tests live at `plans/<slug>/scaffold/issue-N.bats` (one file per issue). The `<slug>` is the git branch slug, same as the rest of the plan.
- **Lifecycle**: scaffolding tests are versioned (not gitignored), treated as plan artifacts alongside `state.json` and `progress.md`. They are deleted by the human when archiving the plan.
- **Issue schema**: two independent optional fields added to the issue template:
  - `scaffolding-test:` — prose description of what the scaffolding test should verify (omit if no scaffolding needed)
  - `permanent-test:` — prose description of what the permanent test should verify (omit if no permanent test needed)
  - Both present = mixed task. One present = single-type task. Both absent = no tests (e.g. config-only change).
- **Ralph override**: Ralph reads the fields from the issue as the default, but can enrich or change them based on implementation context (e.g. discovering that existing permanent tests already cover the behavior makes a new permanent test redundant; or a task declared as scaffolding-only turns out to also introduce new behavior).
- **Declaration step** in Ralph Step 2 (RED): before writing any test, Ralph announces the test strategy — what goes in scaffolding, what goes in permanent — as an explicit reasoning step visible to the user.
- **ToIssues** populates the fields during issue drafting, based on the issue type (feature → `permanent-test`, refactoring → `scaffolding-test`, mixed → both). ToIssues presents them in the Step 3 confirmation so the user can review.
- **No new runtime tool**: scaffolding tests are run by the agent explicitly via `bats plans/<slug>/scaffold/issue-N.bats`, not through the global test runner. Pre-commit picks them up only if the files were modified (lint-staged behavior already in place).

## Testing Decisions

No bats or vitest tests. The modified files are markdown skill definitions — the files themselves are the artifact. This follows the established project convention (see `feedback_no_lint_config_tests.md`).

## Out of Scope

- The "signature change" edge case (function API changes that affect callers) — left for later iteration with real usage data.
- A subsidiary rule like "any test containing `grep` on a source file is always scaffolding" — omitted intentionally to let the agent reason rather than pattern-match.
- Automatic deletion of scaffolding tests by the agent — human handles this at plan-archive time.
- Changes to the `test-driven-development` skill (separate from `tdd`) — out of scope.
