## TLDR

Declare Worktree Badge colors in `O.colors.statusline`.

## What to build

Add a `worktree` entry to the statusline color table (alongside existing entries like `normal`, `insert`, `search`…). The colors must match the zsh `context-badge` function exactly: `ORANGE_7` background and `ORANGE_1` foreground — these correspond to ANSI 130 and 208 respectively.

## Acceptance criteria

- [ ] `O.colors.statusline.worktree` exists with `bg = "ORANGE_7"` and `fg = "ORANGE_1"`
- [ ] The entry is placed alongside the other statusline color declarations (not inline in rendering code)
