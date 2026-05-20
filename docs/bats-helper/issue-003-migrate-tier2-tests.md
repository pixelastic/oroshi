## PRD

[PRD.md](./PRD.md) — Bats Helper Redesign

## What to build

Migrate all Tier 2 test files to the new helper. These tests need a git repo (and in some
cases a worktree) but no mocks:

- `config/term/zsh/functions/autoload/git/github/__tests__/git-github-project-name.bats`
- `config/term/zsh/functions/autoload/git/github/__tests__/git-github-project-owner.bats`
- `config/term/zsh/functions/autoload/git/github/__tests__/git-github-project.bats`
- `config/term/zsh/functions/autoload/git/file/__tests__/git-file-list-dirty-raw.bats`
- `scripts/bin/ai/review/__tests__/review-diff.bats`
- `config/term/zsh/functions/autoload/git/directory/__tests__/git-directory-is-worktree.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-project.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-path.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-pull.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-is-behind.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-is-ahead.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-main.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-distance.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-list.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-list-raw.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-push.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-delete.bats`
- `config/term/zsh/functions/autoload/git/worktree/__tests__/git-worktree-switch.bats`
- `config/term/zsh/functions/autoload/completion/__tests__/complete-git-worktrees.bats`
- `config/term/zsh/functions/autoload/completion/__tests__/complete-git-worktrees-linked.bats`
- `config/term/zsh/prompt/__tests__/index.zsh.bats`

Replace manual `git init` + config + commit boilerplate with `bats_git_dir`. Replace manual
`git worktree add` boilerplate with `bats_git_worktree`. Replace `run_zsh_fn` with
`bats_run_function`. Add `bats_cleanup` in teardown.

Where tests strip ANSI codes inline with `sed`, replace with `bats_strip_ansi`.

## Acceptance criteria

- [ ] No test file in the list uses manual `git init` / `git config` / `git commit --allow-empty`
  boilerplate — all replaced by `bats_git_dir`
- [ ] No test file uses manual `git worktree add` boilerplate — all replaced by `bats_git_worktree`
- [ ] No test file references `run_zsh_fn` or `TMP_DIRECTORY`
- [ ] Inline `sed` ANSI stripping replaced with `bats_strip_ansi` where present
- [ ] All tests in all listed files pass

## Blocked by

- issue-002
