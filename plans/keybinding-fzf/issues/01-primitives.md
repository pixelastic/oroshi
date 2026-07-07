## TLDR

Add two reusable Kitty remote-control primitives: one to resolve an overlay's parent window ID, one to type text into a window by ID.

## What to build

Add `kitty-overlay-window-id` to `scripts/bin/kitty/`: reads `$KITTY_WINDOW_ID` from the environment, queries `kitty-remote ls`, and prints the `overlay_for` value — the ID of the window this overlay covers. Exits non-zero if the current window is not an overlay.

Add `kitty-window-send-text` to `scripts/bin/kitty/`: accepts a window ID and a text argument, and sends that text to the target window as keyboard input via `kitty-remote send-text --match "id:<windowId>"`.

Both scripts use the existing `kitty-remote` wrapper (handles the Unix socket path) and follow the same interface conventions as the other `kitty-window-*` scripts.

## Acceptance criteria

- [ ] `kitty-overlay-window-id` prints the parent window ID when run inside an overlay
- [ ] `kitty-overlay-window-id` exits non-zero when `overlay_for` is null (not an overlay)
- [ ] `kitty-window-send-text <id> <text>` forwards the text to the correct window via `kitty-remote`
- [ ] `kitty-window-send-text` prints a usage error and exits non-zero when called without arguments
- [ ] Both scripts follow the `#!/usr/bin/env zsh` + `set -e` + header comment convention of the existing kitty scripts
