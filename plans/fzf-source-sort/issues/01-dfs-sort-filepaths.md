## TLDR

Rewrite `sort-filepaths` to produce DFS files-first ordering, and add a unit test file.

## What to build

Replace the current weight-based logic in `sort-filepaths` (weight 1 = root, weight 2 = downward, weight 3 = `../`) with a DFS files-first algorithm.

The new ordering: root files first (alphabetically), then for each immediate subdirectory (alphabetically), all its direct files appear before recursing into its own subdirectories. Paths starting with `../` continue to sort last.

The function signature is unchanged: accepts filepaths via stdin or as arguments, outputs sorted filepaths on stdout.

Create a new bats test file for `sort-filepaths` in the `misc/__tests__/` directory. Tests feed string lists directly into the function — no filesystem setup required.

## Behavioral Tests

**Root files before subdirectory files**
- Root files appear before any file with a `/` in its path

**Files before subdirectories at each level**
- Given files at `a/file.txt` and `a/sub/nested.txt`, `a/file.txt` appears first
- Given `__lib/foo.zsh` and `__lib/__tests__/bar.bats`, `__lib/foo.zsh` appears first

**Alphabetical ordering within same level**
- Root files are sorted alphabetically among themselves
- Files within the same directory are sorted alphabetically

**Upward paths sort last**
- A `../sibling` path appears after all downward paths

**Edge cases**
- Single-file input returns unchanged
- Empty input returns empty

## Acceptance criteria

- [ ] `sort-filepaths` produces DFS files-first order for downward paths
- [ ] Root files appear before any nested file
- [ ] Files in a directory appear before that directory's subdirectories
- [ ] `../` paths continue to sort after all downward paths
- [ ] All behavioral tests pass (`bats` on the new test file)
- [ ] `zsh-lint` passes on the modified `sort-filepaths`
- [ ] `bats-lint` passes on the new test file
