## TLDR

Add Worktree Badge to the statusline and fix the filepath root computation.

## What to build

### `getContextBadge(filepath)` — new function

Extract the project badge resolution from `getFileData()` into a new `getContextBadge()` function. This function also resolves the Worktree Badge:

- Calls `git-worktree-name <filepath>` to detect whether a linked worktree is active
- Returns `{ projectBadge, worktreeBadge }` where `worktreeBadge` is `nil` when not in a worktree
- `projectBadge` carries `{ content, hl }` — same shape as today
- `worktreeBadge` carries `{ content, hl }` using `O.colors.statusline.worktree`

### Filepath root fix

Replace the current project-path stripping with a call to `context-root <filepath>`. This returns the worktree root inside a linked worktree, and the project root otherwise — making `simplify-path` work correctly in both cases.

### `main()` rendering

Update the left-section rendering to:

1. Mode badge
2. Arrow: `fg = modeBg`, `bg = projectBadge.hl.bg`
3. Project Badge
4. **If worktree active:** arrow `fg = projectBadge.hl.bg` / `bg = worktreeBadge.hl.bg` → Worktree Badge → arrow `fg = worktreeBadge.hl.bg` (no bg)
5. **If no worktree:** arrow `fg = projectBadge.hl.bg` (no bg)
6. Filepath

The filepath, worktreeBadge, and contextRoot are cached in `vim.b.statuslineFileData` alongside the existing project and file data.

## Acceptance criteria

- [ ] Inside a linked worktree: the Worktree Badge (branch name, orange) appears between Project Badge and filepath
- [ ] Outside a worktree: no Worktree Badge is shown; separator arrow ends cleanly with no background
- [ ] The powerline arrow between Project Badge and Worktree Badge uses the worktree orange as background
- [ ] The powerline arrow after the Worktree Badge has no background (transparent)
- [ ] Inside a worktree: the filepath is relative to the worktree root, not the project root
- [ ] Outside a worktree: the filepath is relative to the project root (unchanged behavior)
- [ ] `simplify-path` correctly shortens the path in both cases
- [ ] The Worktree Badge content matches the branch name returned by `git-worktree-name`
- [ ] Special buffers (healthcheck, CodeCompanion, kitty pager) are unaffected
- [ ] NvimTree buffer is unaffected
