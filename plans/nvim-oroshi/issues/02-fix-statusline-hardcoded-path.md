## TLDR

Replace the single hardcoded `~/.oroshi` path in `statusline.lua` with `vim.env.OROSHI_ROOT`.

## What to build

In `tools/vim/nvim/config/lua/oroshi/ui/statusline.lua` (path after issue 01 rename), one line loads project data for the statusline using a hardcoded `~/.oroshi/...` path. Replace it with `vim.env.OROSHI_ROOT .. "/..."`, consistent with how all other external-command paths are written in the codebase (see `filetypes/colors.lua` for prior art).

## Behavioral Tests

Skip — single-line path substitution, no new behavior.

## Scaffolding Tests

Skip.

## Acceptance criteria

- [ ] No hardcoded `~/.oroshi` path remains in the statusline module
- [ ] The project data path uses `vim.env.OROSHI_ROOT`
- [ ] Statusline loads the correct `projects.json` when `$OROSHI_ROOT` points to a worktree
