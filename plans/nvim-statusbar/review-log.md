## Issue 03 — Context Badge Rendering

### Arrow glyph `">"` instead of U+E0B0
```lua
add(statusline, ">", { fg = projectBadge.hl.bg, bg = worktreeBadge.hl.bg })
add(statusline, worktreeBadge.content, worktreeBadge.hl)
add(statusline, ">", { fg = worktreeBadge.hl.bg })
```
**Problem:** Reviewer flagged that `">"` is plain ASCII, not the Powerline arrow U+E0B0 that the spec and existing code use.
**Reason skipped:** User explicitly requested a placeholder character during implementation (the Write tool strips U+E0B0 silently and Edit cannot reliably output it in new_string). User will replace `">"` with the correct glyph manually.

### Color key `O.colors.statusline.worktreeBadge` vs `.worktree`
```lua
hl = O.colors.statusline.worktreeBadge,
```
**Problem:** Reviewer flagged that spec L14 says `O.colors.statusline.worktree` but implementation uses `worktreeBadge`.
**Reason skipped:** GUIDANCE.md Issue 02 discovery explicitly overrides this: "Key must be `worktreeBadge` (not bare `worktree`)". The color entry in `colorscheme/ui.lua` is also named `worktreeBadge`. Guidance discovery takes precedence over the spec text.
