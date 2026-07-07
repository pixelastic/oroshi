## TLDR

Add `kitty-ctrl-p` (with tests) and wire it to `alt+p` in Kitty, so any window can open the file picker and insert the selection at the cursor.

## What to build

Add `kitty-ctrl-p` to `scripts/bin/kitty/`: calls `kitty-overlay-window-id` to get the parent window ID, runs `ctrl-p` to open the file picker, shell-quotes the selected path(s), and sends the result to the parent window via `kitty-window-send-text`. Appends a trailing space so the cursor is ready for the next token. Exits cleanly with no side effects if the user cancels (no selection).

Multi-path handling mirrors the ZSH `ctrl-p` widget: output is split on newlines into an array, each element quoted with `${(q-)}`, then space-joined.

Add `map alt+p launch --type=overlay --cwd=current kitty-ctrl-p` to `tools/term/kitty/config/keybindings.conf`, in the `# [Alt-P]` slot (currently marked TODO).

Add `scripts/bin/kitty/__tests__/kitty-ctrl-p.bats` with behavioral tests.

## Behavioral Tests

Collaborators mocked: `kitty-overlay-window-id`, `ctrl-p`, `kitty-window-send-text`.

**Single selection**
- Sends the selected path followed by a trailing space to the parent window

**Multi-selection**
- Sends all paths shell-quoted and space-joined, with a trailing space

**Path containing spaces**
- The path is shell-quoted so it arrives as a single token

**No selection — ctrl-p exits non-zero**
- Nothing is sent to the parent window
- Script exits with status 0

**Empty output from ctrl-p**
- Nothing is sent to the parent window
- Script exits with status 0

## Acceptance criteria

- [ ] `alt+p` in any Kitty window opens the `ctrl-p` file picker in an overlay
- [ ] Selecting a single file inserts the absolute path + trailing space into the parent window
- [ ] Selecting multiple files inserts all paths shell-quoted and space-joined
- [ ] Paths with spaces are correctly quoted
- [ ] Pressing `escape` (no selection) closes the overlay with no text inserted
- [ ] All behavioral test cases pass
- [ ] Keybinding added in the `# [Alt-P]` slot in `keybindings.conf`
