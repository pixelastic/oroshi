## PRD

[PRD.md](./PRD.md) — Bats Helper Redesign

## What to build

Migrate all Tier 3 test files to the new helper. These tests need a git repo and mocks:

- `scripts/bin/ai/ralph/__tests__/ralph.bats` — mocks `inotifywait`, `audio-play-oroshi`,
  `claude`, `git-commit-message`
- `scripts/bin/ai/review/__tests__/review.bats` — mocks `claude-print` (currently via ZDOTDIR
  override)
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-create.bats` —
  mocks `yarn`

For each file, replace the existing mock mechanism with `bats_mock`: define the mock function
as real zsh code, then call `bats_mock funcname` to serialize and unset it.

`review.bats` currently uses a complex ZDOTDIR-based approach to shadow `claude-print`. This
should be replaced with `bats_mock claude-print` since `bats_run_script` now injects mocks
before execution, making the ZDOTDIR workaround unnecessary.

## Acceptance criteria

- [ ] `ralph.bats` defines mock functions as real code and calls `bats_mock` to register them
- [ ] `review.bats` removes the ZDOTDIR override; uses `bats_mock claude-print` instead
- [ ] `git-worktree-create.bats` uses `bats_mock yarn` instead of a manually created
  executable in PATH
- [ ] No test file in the list uses the old `mock` function name
- [ ] All tests in all three files pass

## Blocked by

- issue-003
