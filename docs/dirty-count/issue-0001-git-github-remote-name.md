# 0001 — `git-github-project-name` (was: `git-github-remote-name`)

## Status: DONE — superseded by existing function

The original spec described creating a new `git-github-remote-name` helper.
This was resolved by the existing `git-github-project-name` function (part of
the `git-github-project` / `git-github-project-name` / `git-github-project-owner`
trio, renamed from `git-github-remote-*` via commit `73a53ae6`).

The fallback behaviour (no remote → folder name, strip leading dots) is handled
inline in `git-worktree-create` (issue 0002), not in a separate function.

## Acceptance criteria (all satisfied)

- [x] Returns repo name from a SSH GitHub remote URL (`git@github.com:owner/repo.git` → `repo`) — via `git-github-project-name`
- [x] Returns repo name from a HTTPS GitHub remote URL (`https://github.com/owner/repo.git` → `repo`) — via `git-github-project-name`
- [x] Falls back to folder name (without leading dots) when no remote — inline in `git-worktree-create`
- [x] Strips all leading dots from the fallback folder name (`.myrepo` → `myrepo`) — inline in `git-worktree-create`
