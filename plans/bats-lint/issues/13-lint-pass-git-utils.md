## TLDR

Lint pass on git utility tests — branch, directory, file, github, remote, tag (16 files).

## What to build

Run `bats-lint` on all git utils tests (excluding worktree). Files cover: git-branch-*, git-directory-*, git-file-*, git-github-*, git-remote-colorize, git-tag-colorize, git-distance-parse. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 16 files
- [ ] `bats` passes on all 16 files
- [ ] Developer review sign-off
