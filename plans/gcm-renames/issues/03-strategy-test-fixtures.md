## TLDR

Add rename and binary fixtures to `commitWithHint` and `commitWithoutHint` tests.

## What to build

Update the existing test files for both strategies to include rename scenarios. Since `getDiff` is now a shared module, these tests verify that each strategy correctly delegates to it and passes the right exclusion list.

The Gilmore mock must now provide `stagedFilesWithStatus()` instead of (or alongside) `stagedFiles()`. Add test cases for:

- Rename-only files → rename fallback
- Mixed rename + content → content diff + rename block
- Binary files → binary fallback (already covered, but update mock shape)

## Behavioral Tests

**commitWithHint:**
- rename-only staged files → returns `Files renamed:` block
- mixed rename + text → returns diff + rename block
- plan-noise files excluded from rename fallback

**commitWithoutHint:**
- rename-only staged files → returns `Files renamed:` block
- mixed rename + text → returns diff + rename block
- yarn.lock excluded from all processing

## Acceptance criteria

- [ ] `commitWithHint` tests include rename fixtures
- [ ] `commitWithoutHint` tests include rename fixtures
- [ ] Existing test cases updated to use new mock shape
- [ ] All tests pass
