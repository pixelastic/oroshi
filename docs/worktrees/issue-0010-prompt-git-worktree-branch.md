# 0010 — `git_worktree_branch` prompt part

## What to build

A new **asynchronous** prompt part `git_worktree_branch` that replaces
`git_is_worktree`. When inside a Worktree it displays:

```
 fix/bug
```

Where:
- `` (\uf06c) is the leaf icon — displayed **before** the branch name
- Icon color: `COLOR_ALIAS_GIT_WORKTREE` (orange) when 0 commits ahead of `main`;
  `COLOR_ALIAS_GIT_TRACKED` (purple) when ≥ 1 commit ahead. Ahead count via
  `git-worktree-distance`.
- Branch name: colorized via `git-branch-colorize` (no icon — the leaf carries
  the worktree signal)
- When not in a Worktree: empty string

The right prompt (`git_branch`) must be suppressed when `GIT_DIRECTORY_IS_WORKTREE == 1`
to avoid showing the branch name twice.

Migration:
- Remove `git_is_worktree` from `OROSHI_SYNCHRONOUS_PROMPT_PARTS`
- Add `git_worktree_branch` to `OROSHI_ASYNCHRONOUS_PROMPT_PARTS`
- Replace `$OROSHI_PROMPT_PARTS[git_is_worktree]` with
  `$OROSHI_PROMPT_PARTS[git_worktree_branch]` in `oroshi-prompt-left`
- Add guard in `oroshi-prompt-right`: skip `git_branch` when
  `GIT_DIRECTORY_IS_WORKTREE == 1`

## Acceptance criteria

- [ ] Inside a Worktree, the left prompt shows the leaf icon `` before the branch name
- [ ] Icon is orange when the Worktree has 0 commits ahead of `main`
- [ ] Icon is purple when the Worktree has ≥ 1 commit ahead of `main`
- [ ] Branch name is not shown in the right prompt when inside a Worktree
- [ ] Outside a Worktree, `git_worktree_branch` is empty and `git_branch` appears on the right as before
- [ ] `git_is_worktree` is retired (removed from prompt parts and git.zsh)

## Blocked by

- issue-0005 (`git-worktree-distance` must exist first)
- issue-0007 (`GIT_DIRECTORY_IS_WORKTREE` cache must exist first)
