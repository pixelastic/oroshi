# 0008 — `git-worktree-project`

## What to build

A new helper in the `git/worktree/` family that returns the project name for the
current Worktree.

Logic: call `git-worktree-main` to get the Git Repo Main path, then pass that
path to `project-by-path` to resolve the registered project name.

Returns an empty string if the Git Repo Main does not match any known project.
Can be called standalone or used by the prompt.

## Acceptance criteria

- [ ] Returns the correct project name when in a Worktree whose Git Repo Main is a registered project
- [ ] Returns an empty string when in a Worktree whose Git Repo Main is not a registered project

## Blocked by

None — can start immediately.
