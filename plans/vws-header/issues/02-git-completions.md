## TLDR

Migrate all 10 git `compdef` completion functions to use `$COLORS[key]` and `$ICONS[key]`, and add the two load-definitions calls.

## What to build

Update these files under `tools/term/zsh/config/completion/compdef/`:
`_git-worktrees`, `_git-worktrees-linked`, `_git-branches-local`, `_git-branches-remote`, `_git-tags-local`, `_git-tags-remote`, `_git-remotes`, `_git-submodules`, `_git-files-stageable`, `_git-files-staged`

For each file:
1. Add `colors-load-definitions` and `icons-load-definitions` as the first two statements inside the function body (deduplicate any existing multiple calls).
2. Replace `$COLOR_ALIAS_*` with `$COLORS[key]` and `$COLOR_WHITE`/`$COLOR_BLACK` with `$COLORS[white]`/`$COLORS[black]`.
3. Replace any hardcoded Nerd Font glyphs in the header label with `$ICONS[key]` references.
4. Add a `$ICONS[key]` reference to header labels that currently have none.

Color mappings for this group:
- `COLOR_ALIAS_GIT_WORKTREE` → `$COLORS[git-worktree]`
- `COLOR_ALIAS_GIT_BRANCH` → `$COLORS[git-branch]`
- `COLOR_ALIAS_GIT_TAG` → `$COLORS[git-tag]`
- `COLOR_ALIAS_GIT_REMOTE` → `$COLORS[git-remote]`
- `COLOR_ALIAS_GIT_SUBMODULE` → `$COLORS[git-submodule]`
- `COLOR_ALIAS_GIT_MODIFIED` → `$COLORS[git-modified]`

Icon mappings for this group:
- `_git-worktrees` / `_git-worktrees-linked` → `$ICONS[git-worktree]`
- `_git-branches-*` → already uses `$ICONS[git-branch]`
- `_git-tags-local` → `$ICONS[git-tag]`
- `_git-tags-remote` → already uses `$ICONS[git-tag]`
- `_git-remotes` → already uses `$ICONS[git-remote]`
- `_git-submodules` → already uses `$ICONS[git-submodule]`
- `_git-files-stageable` / `_git-files-staged` → hardcoded glyph → `$ICONS[git-commit]`

## Acceptance criteria

- [ ] All 10 files have `colors-load-definitions` + `icons-load-definitions` as the first two function statements
- [ ] No file calls `icons-load-definitions` more than once
- [ ] No `$COLOR_ALIAS_*`, `$COLOR_WHITE`, or `$COLOR_BLACK` references remain
- [ ] No hardcoded Nerd Font glyphs remain in header labels
- [ ] All header labels include a `$ICONS[key]` reference
- [ ] `zsh-lint` passes on all 10 files
