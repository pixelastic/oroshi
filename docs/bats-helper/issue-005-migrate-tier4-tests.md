## PRD

[PRD.md](./PRD.md) — Bats Helper Redesign

## What to build

Migrate the Tier 4 test files to the new helper. These tests source oroshi config files
directly and set up complex environment variables:

- `config/term/zsh/prompt/__tests__/git.zsh.bats`
- `config/term/zsh/prompt/__tests__/path.zsh.bats`

These tests are the most complex: they source `zshenv.zsh` and prompt config files, manually
set color variables and prompt parts arrays, and test rendered prompt output. Migrate them to
use `bats_git_dir`, `bats_git_worktree`, `bats_strip_ansi`, and `bats_cleanup`.

The sourcing of oroshi config files is intentional and must be preserved — it is not a mock
target but part of the test setup for the prompt rendering system.

## Acceptance criteria

- [ ] `git.zsh.bats` uses `bats_git_dir` and `bats_git_worktree` for git state setup
- [ ] `path.zsh.bats` uses `bats_git_dir` and `bats_git_worktree` for git state setup
- [ ] Both files use `bats_strip_ansi` where ANSI stripping was previously done inline
- [ ] Both files use `bats_cleanup` in teardown
- [ ] No reference to old helper names in either file
- [ ] All tests in both files pass

## Blocked by

- issue-004
