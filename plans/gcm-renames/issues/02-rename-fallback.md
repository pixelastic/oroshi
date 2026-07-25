## TLDR

Add rename-only detection and a fallback block in `getDiff` for 100%-similarity renames.

## What to build

In `getDiff.js`, after getting `stagedFilesWithStatus()` results and filtering exclusions, classify files into three buckets:

- **rename-only**: `status === 'renamed'` and `similarity === 100` — skip diffing, collect `from` and `name` for the fallback block
- **diffable**: everything else — diff with `git diff --cached -M -- <filepath>`
- **binary**: diffable files whose diff result is empty

Assemble the final string in order:
1. Content diffs (joined, trimmed)
2. `Files renamed:\n- old/path → new/path` (if any renames)
3. `Binary files added:\n- file` (if any binaries)

Empty blocks are omitted. Blocks are separated by `\n\n`.

## Behavioral Tests

**Rename-only scenario:**
- all staged files are 100% renames → returns `Files renamed:\n- old → new`

**Content-only scenario:**
- no renames → returns raw diff (existing behavior)

**Binary-only scenario:**
- no renames, empty diffs → returns `Binary files added:\n- file` (existing behavior)

**Mixed scenarios:**
- rename + content → content diff + rename block
- rename + binary → rename block + binary block
- rename + content + binary → content diff + rename block + binary block

**Filtering:**
- excluded files are not diffed and not listed in any fallback block

## Acceptance criteria

- [ ] 100%-similarity renames produce `Files renamed:` fallback block
- [ ] Renames with < 100% similarity are diffed normally
- [ ] Assembly order: content, then renames, then binaries
- [ ] Empty blocks are omitted
- [ ] Excluded files filtered from all categories
- [ ] All getDiff tests pass
