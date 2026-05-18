## PRD

`docs/context-badge/PRD.md`

## What to build

Update the shell prompt to use `context-badge`.

**`path` prompt part**: replace the `project-colorize` call (and associated `project-by-path` / `git-worktree-project` logic) with a single `context-badge --zsh` call. Remove the async `git_worktree_branch` prompt part — the branch is now rendered synchronously inside `context-badge`.

**`path_worktree_dir` prompt part**: replace the manual worktree path-stripping dance with `context-root` / `context-path`. Output remains the same (sub-path relative to the Context Root, simplified).

## Acceptance criteria

- [ ] Prompt shows project name only when inside a Git Repo Main
- [ ] Prompt shows project name + branch name when inside a linked Worktree
- [ ] Prompt shows project name in a non-git registered project directory
- [ ] Sub-path shown after the badge is relative to the Context Root (worktree root when in a worktree, project root otherwise)
- [ ] No async `git_worktree_branch` prompt part remains
- [ ] Existing `oroshi-prompt-path-worktree` BATS tests still pass

## Blocked by

- issue-003 (`--zsh` flag required for prompt color codes)
