## TLDR

Rewrite `testing.md` from 6 sections to 4, absorbing Mocking and it.each into a new Test structure section.

## What to build

Rewrite `tools/ai/claude/config/skills/js-writer/references/testing.md` with this structure:

**Section 1 — Test file naming** (keep existing content unchanged)

**Section 2 — Test structure** (new, absorbs old Mocking and it.each)

Bullet rules:
- Shared mocks in `beforeEach` — set up once, not per test
- Import `__` to spy/mock private functions
- Use `vi.spyOn(__, 'method').mockReturnValue(...)` for mocks
- DO NOT use `mockResolvedValue` or `mockRejectedValue`, use `mockReturnValue`
- Prefer `it.each` when testing same setup with different inputs
- Use `input` and `expected` keys in `it.each`. Use `title` key if input is too long
- Use standalone `it` for side effects, error cases, or anything that doesn't fit input/output variation
- Override a mock inside a specific `it` if needed

One comprehensive example showing:
- `beforeEach` with one `vi.spyOn(__, 'method').mockReturnValue({...})`
- `it.each` with `input`/`expected` keys for variations
- One standalone `it` asserting a side effect (e.g., `expect(__.save).toHaveBeenCalled()`)

**Section 3 — Filesystem tests** (new)

Bullet rules:
- `let testDirectory` at describe scope
- Assign `testDirectory = tmpDirectory('scope')` in `beforeEach` (synchronous, no async)
- Clean up via `await remove(testDirectory)` in `afterEach` (NOT in `beforeEach`)
- Each `it` does its own filesystem work

Minimal example showing `let testDirectory`, `beforeEach`, `afterEach`, and an empty `it` using `testDirectory` as path root.

**Section 4 — Assertions** (renamed from "Error testing", expanded)

Bullet rules:
- Use `try`/`catch` with `let actual` to test errors (keep existing example)
- Prefer `toEqual` with the exact expected value when the full content is known
- Reserve `arrayContaining`/`objectContaining` for genuine subset tests

## Acceptance criteria

- [ ] File has exactly 4 sections: Test file naming, Test structure, Filesystem tests, Assertions
- [ ] Old Mocking section removed — rules absorbed into Test structure bullets
- [ ] Old it.each section removed — rules absorbed into Test structure bullets
- [ ] Test structure has one comprehensive example with `beforeEach` + `it.each` + standalone `it`
- [ ] Filesystem tests example uses `testDirectory` variable name (not `tmpDir`)
- [ ] Filesystem tests `beforeEach` is not async
- [ ] Assertions section contains existing try/catch example
- [ ] Assertions section contains `toEqual` vs `arrayContaining` rule
- [ ] File is under 120 lines
