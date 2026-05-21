## PRD

[vws-completion/PRD.md](./PRD.md)

## What to build

Add a `zstyle list-colors` entry for `git-worktree-switch` in `styling.zsh`, using the existing `listColorsGitBranch` palette. This makes `main` appear in blue and all other worktree names in orange — consistent with branch completion coloring. No new color palette is needed.

## Acceptance criteria

- [ ] `styling.zsh` contains a `zstyle` entry for `git-worktree-switch` with `listColorsGitBranch`
- [ ] The entry follows the same pattern as the existing branch `zstyle` entries in that file

## Blocked by

None — can start immediately
