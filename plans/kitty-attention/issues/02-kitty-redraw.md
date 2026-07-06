## TLDR

Create `kitty-redraw` — the lightweight script that forces an immediate Tab Bar Redraw.

## What to build

Create a new script `scripts/bin/kitty/kitty-redraw` that encapsulates the
Redraw mechanism confirmed in issue 01.

Usage:
- `kitty-redraw` — Redraw the Tab Bar for all tabs (current limitation of the hack)

The script calls `kitty @ set-tab-color --match all active_bg=NONE` to trigger
`mark_tab_bar_dirty()` inside Kitty, which schedules a Tab Bar re-render on the
next frame. No data is reloaded from disk.

## Acceptance criteria

- [ ] Script exists at `scripts/bin/kitty/kitty-redraw`
- [ ] Calling it forces a Tab Bar Redraw without reloading any JSON data
- [ ] Script is silent on success, exits non-zero if Kitty is unreachable
- [ ] Script is linted with `zsh-lint`
