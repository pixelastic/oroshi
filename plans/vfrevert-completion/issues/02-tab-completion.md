## TLDR

Add Tab completion to `vfrevert` / `git-file-revert` listing all dirty files with status annotations.

## What to build

Three pieces wired together end-to-end:

1. **`complete-git-files-dirty`** — new autoload function (in `autoload/completion/`) that calls `git-file-list-dirty-raw`, sorts results by proximity via `sort-filepaths`, and outputs `filepath:status-label` pairs where labels are `- Deleted`, `~ Modified`, `+ New file`.

2. **`_git-files-dirty`** — new compdef function (in `completion/compdef/`) that calls `complete-git-files-dirty`, wraps the output in `_describe` with a colored header labeled "Dirty files" (same icon and `completion-header` pattern as `_git-files-dirty-stageable`).

3. **`compdef.zsh`** — register `_git-files-dirty` for `git-file-revert`. No need to register the `vfrevert` alias — ZSH expands aliases before completion lookup.

Prior art: `complete-git-files-dirty-stageable` and `_git-files-dirty-stageable`.

## Acceptance criteria

- [ ] `vfrevert <Tab>` lists all dirty files (modified, deleted, staged-new, untracked)
- [ ] Each entry shows a status annotation (`~ Modified`, `- Deleted`, `+ New file`)
- [ ] Files closest to `$PWD` appear first
- [ ] `zsh-lint` passes on all new/modified files
