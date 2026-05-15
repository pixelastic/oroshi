# 0009 — `oroshi-prompt-populate:path` — worktree project detection

## What to build

Update `oroshi-prompt-populate:path` so that when inside a Worktree, the project
prefix shows the parent project (e.g. `[oroshi]`) rather than a raw filesystem
path.

Replace the current `project-by-path` call with branching logic:

- If `GIT_DIRECTORY_IS_WORKTREE == 1` → call `git-worktree-project` to resolve
  the parent project name
- Else → call `project-by-path $PWD` (unchanged behaviour)

The path segment after the prefix remains relative to the worktree root — same
behaviour as relative-to-project-root today. No branch name appears in the path
segment; the `git_worktree_branch` prompt part (issue 0010) carries that.

## Acceptance criteria

- [ ] When inside a Worktree of a registered project, the prompt displays the project prefix (e.g. `[oroshi]`)
- [ ] When inside a Worktree of an unregistered project, the prompt falls back to a plain path (no prefix)
- [ ] The path shown after the prefix is relative to the worktree root, not the absolute path
- [ ] Behaviour outside of Worktrees is unchanged

## Blocked by

- issue-0007 (`GIT_DIRECTORY_IS_WORKTREE` cache must exist first)
- issue-0008 (`git-worktree-project` must exist first)
