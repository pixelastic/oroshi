## PRD

[PRD — review-diff + review skill overhaul](./PRD.md)

## What to build

Create `scripts/bin/ai/review-diff` as a zsh script that handles the 0-argument case: emit the full working-tree diff including untracked files, all output through `rtk`.

- `git diff HEAD` covers tracked modifications and staged changes
- Untracked files (`git status --porcelain | grep '^??'`) are each emitted as a new-file diff via `git diff --no-index /dev/null <file>`
- All output-producing git calls pipe through `rtk`; branch detection and file enumeration do not
- Output: stat + full diff, raw concatenation, no section headers
- 0-arg clean tree: exits 0, empty output

Also create `scripts/bin/__tests__/review-diff.bats` with the 0-arg test cases (setup/teardown follows the `git-worktree-list.bats` pattern).

## Acceptance criteria

- [ ] `review-diff` exists at `scripts/bin/ai/review-diff` and is executable
- [ ] 0-arg, clean tree: exits 0, produces no output
- [ ] 0-arg, modified tracked file: stdout contains the diff hunk
- [ ] 0-arg, untracked file: stdout contains a `diff --git` new-file block for the untracked file
- [ ] 0-arg, staged file: stdout contains the staged hunk
- [ ] All 4 bats tests pass

## Blocked by

None — can start immediately
