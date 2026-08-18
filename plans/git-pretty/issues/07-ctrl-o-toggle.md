## TLDR

Ctrl+O toggles raw git output below the pretty display during push.

## What to build

Add keyboard handling to the bubbletea TUI:

- Ctrl+O toggles a "raw output" panel below the pretty progress/summary line
- When open: all raw stderr lines (buffered since the start) are displayed below a separator line
- New lines append in real-time while the push is still running
- When closed: the raw panel disappears, only the pretty line remains
- Toggle works during the push only (after exit, Ctrl+O is just a normal terminal key)
- The raw output buffer accumulates all stderr lines from the start, regardless of toggle state

## Acceptance criteria

- [ ] Ctrl+O opens raw output panel below pretty display
- [ ] Ctrl+O again closes it
- [ ] Raw panel shows all stderr from the beginning (not just from when toggled)
- [ ] New lines appear in real-time while open
- [ ] Toggle works multiple times
- [ ] After program exits, raw panel (if open) stays printed in terminal
