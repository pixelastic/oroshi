## Problem Statement

The js-writer testing skill (`testing.md`) has rules that are too vague to prevent bad patterns. During a code review, three weaknesses were identified: loose `arrayContaining` + `toHaveLength` used when full content was known, shared mocks designed for the minimal case forcing most tests to override them, and underuse of `it.each` when tests shared the same structure but differed in fixtures.

## Solution

Restructure `testing.md` from 4 sections to 8 sections, introducing explicit guidance on setup design philosophy ("build a single rich context, don't design a different world per test"), lifecycle hooks, and `it.each` vs standalone `it`. Add a Common Rationalizations section to catch known agent failure modes. Unify all code examples around a single domain (`getOrders`) for coherence.

## User Stories

1. As a code-writing agent, I want clear guidance on shared setup design, so that I build a single rich context shared across tests instead of overriding the mock in every test.
2. As a code-writing agent, I want to know when to use `it.each` vs standalone `it`, so that I collapse structurally identical tests into `it.each` rows instead of writing repetitive standalone tests.
3. As a code-writing agent, I want explicit rationalizations debunked, so that I don't fall into the trap of using `arrayContaining` + `toHaveLength` when the full expected content is known.
4. As a code-writing agent, I want lifecycle hook guidance, so that I choose `beforeEach` by default and `beforeAll` only when setup is expensive and tests are read-only.
5. As a code-writing agent, I want to know to always clean up in the symmetric hook, so that test isolation is maintained regardless of whether I used `beforeEach` or `beforeAll`.
6. As a code-writing agent, I want all examples in the same domain, so that I can follow the progression from setup to tests without context-switching between unrelated examples.
7. As a code reviewer, I want the testing skill to prevent the patterns I had to flag manually, so that reviews focus on logic rather than repeated structural corrections.

## Implementation Decisions

- **Section restructure:** The file goes from 4 sections (Test file naming, Test structure, Filesystem tests, Assertions) to 8 sections (Test file naming, Test conventions, Setup design, Lifecycle hooks, `it.each` vs standalone `it`, Filesystem tests, Assertions, Common Rationalizations).
- **"Test structure" → "Test conventions":** Retains only mechanical rules (variable names, `describeName`/`testName`, `dedent`, `vi.spyOn` syntax). Setup and `it.each` guidance moves to dedicated sections.
- **Setup design philosophy:** "Prefer building a single rich context shared across tests that covers many edge cases rather than designing a specific context per test. Each test observes a different facet of that same context."
- **Lifecycle hooks:** `beforeEach` by default (fresh context per test). `beforeAll` when setup is expensive and all tests are read-only. Always clean up in the symmetric hook (`afterEach`/`afterAll`). Migrates hook rules from Filesystem tests section.
- **`it.each` vs standalone `it`:** `it.each` when tests share the same structure (same sequence of operations), even if fixtures and expectations differ. Standalone `it` for side effects, errors, or genuinely different flows. Prefer many `it.each` rows over many standalone `it` blocks.
- **Filesystem tests:** Keeps `let testDirectory` pattern and code example. Hook rules migrate to Lifecycle hooks section.
- **Assertions:** Unchanged — keeps existing `toEqual`/`arrayContaining` rules (lines 69-70).
- **Common Rationalizations:** Two entries: (1) `arrayContaining` + `toHaveLength` smell, (2) "if most tests override the setup, the setup is wrong".
- **Example domain:** All code examples use `getOrders(status)` with orders of various statuses (`pending`, `shipped`) and customers (`Alice`, `Bob`). Replaces the current `getData` example.
- **Hook agnosticism in Setup design:** The setup design section does not prescribe where to build the context — that's the Lifecycle hooks section's job.

## Testing Decisions

No tests — this is a skill reference document, not executable code.

## Out of Scope

- Changes to `SKILL.md` (the parent skill's Common Rationalizations section is structural reference only)
- Adding filesystem-based examples to the Setup design section (mock-based example suffices; Filesystem tests section covers filesystem patterns)
- Guidance on test runner configuration, CI, or coverage
- Changes to other js-writer reference files (style, modules, firost, golgoth, aberlaas)
