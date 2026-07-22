## Problem Statement

The js-writer skill's `testing.md` reference doesn't teach test structure patterns — shared setup, `it.each` preference, filesystem lifecycle, or assertion precision. Agents following it produce tests with duplicated mocks per `it`, no `beforeEach`/`afterEach` discipline, and overly permissive assertions like `arrayContaining` when the full value is known.

## Solution

Restructure `testing.md` from six sections to four, consolidating Mocking and it.each into a new "Test structure" section that teaches the preferred pattern through one comprehensive example. Add a "Filesystem tests" section for `tmpDirectory`/`remove` lifecycle. Rename "Error testing" to "Assertions" and add the `toEqual` vs `arrayContaining` rule.

## User Stories

1. As an agent writing JS tests, I want a single example showing shared mocks in `beforeEach` + `it.each` + standalone `it`, so that I produce well-structured tests from the start
2. As an agent writing JS tests, I want to know to use `it.each` for input/output variations of the same setup, so that I don't duplicate test bodies
3. As an agent writing JS tests, I want to know when a standalone `it` is appropriate (side effects, errors), so that I don't force everything into `it.each`
4. As an agent writing JS tests, I want to know the `__` import pattern and `vi.spyOn`/`mockReturnValue` usage, so that I mock correctly
5. As an agent writing JS tests, I want to know not to use `mockResolvedValue`/`mockRejectedValue`, so that I follow project conventions
6. As an agent writing filesystem tests, I want to know the `testDirectory` lifecycle (`tmpDirectory` in `beforeEach`, `remove` in `afterEach`), so that tests don't leak temp files
7. As an agent writing filesystem tests, I want to know the variable is called `testDirectory` (not `tmpDir`), so that naming is consistent across all projects
8. As an agent writing assertions, I want to know to prefer `toEqual` with the exact expected value, so that tests catch unexpected extra items
9. As an agent writing assertions, I want to know to reserve `arrayContaining`/`objectContaining` for genuine subset tests, so that I don't weaken assertions by accident
10. As an agent writing assertions on errors, I want the try/catch + `let actual` pattern, so that I test error properties correctly

## Implementation Decisions

- **Four sections instead of six**: Test file naming, Test structure, Filesystem tests, Assertions. Mocking and it.each are absorbed into Test structure.
- **Test structure section**: Bullet rules first, then one comprehensive example showing `beforeEach` with one `vi.spyOn(__, 'method').mockReturnValue(...)`, followed by `it.each` with `input`/`expected` keys for variations, followed by one standalone `it` for a side effect assertion.
- **it.each key conventions** (`input`, `expected`, `title`) move into Test structure bullets.
- **Mocking rules** (use `__`, no `mockResolvedValue`/`mockRejectedValue`, use `mockReturnValue`) move into Test structure bullets.
- **Filesystem tests section**: `let testDirectory` at describe scope, assigned via `tmpDirectory('scope')` in `beforeEach` (synchronous, no `async`), cleanup via `await remove(testDirectory)` in `afterEach`. Minimal example with no `write` in `beforeEach` — each `it` does its own filesystem work.
- **Assertions section**: Renamed from "Error testing". Keeps existing try/catch example. Adds two bullets: prefer `toEqual` with exact value; reserve `arrayContaining`/`objectContaining` for genuine subsets.
- **Variable name**: `testDirectory` (not `tmpDir`) — matches the convention across firost, keyleth, aberlaas, gilmore.
- **File target**: under 120 lines total.

## Testing Decisions

No tests. This is a skill reference file (documentation), not executable code.

## Out of Scope

- Rewriting existing test files to match the new patterns
- Adding snapshot testing guidance
- Adding coverage configuration guidance
- Adding guidance for non-vitest test runners
