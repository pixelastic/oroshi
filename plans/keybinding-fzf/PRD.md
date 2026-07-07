## Problem Statement

When working in any Kitty window (Claude Code, ZSH, NeoVim command line), there is no way to invoke the project file picker (`ctrl-p`) and insert the selected path at the current cursor position. In ZSH, `ctrl-p` works as a readline widget, but that mechanism is unavailable inside applications with their own input handling (Claude Code, NeoVim insert mode, etc.).

## Solution

A Kitty-level keybinding (`alt+p`) that opens an overlay window running the existing `ctrl-p` file picker. On selection, the chosen path(s) are shell-quoted and sent as keyboard input to the parent window — as if the user had typed them. The feature works universally across all Kitty windows regardless of the running application.

## User Stories

1. As a Kitty user in Claude Code, I want to press `alt+p` to open a file picker and insert the selected path into my prompt, so that I can reference files without typing their paths.
2. As a Kitty user in ZSH, I want to press `alt+p` to open a file picker as an alternative to `ctrl+p`, so that I have a consistent picker available from any context.
3. As a Kitty user, I want the file picker to search from the git root of the current window's working directory, so that results are scoped to the project I'm working in.
4. As a Kitty user, I want to select multiple files using `ctrl-space` and have all paths inserted space-separated, so that I can reference several files in one action.
5. As a Kitty user, I want paths with spaces to be shell-quoted automatically, so that they are safe to use in any command line context.
6. As a Kitty user, I want the picker to close with no effect if I press `escape`, so that accidental triggers don't disrupt my work.
7. As a Kitty user, I want a trailing space inserted after the path(s), so that my cursor is ready to continue typing immediately.
8. As a future script author, I want a `kitty-overlay-window-id` primitive that returns the parent window ID of any overlay, so that other overlay scripts can send output back to their caller without duplicating the lookup logic.
9. As a future script author, I want a `kitty-window-send-text` primitive that types text into a specific window by ID, so that any script can inject keyboard input without knowing the Kitty remote control details.

## Implementation Decisions

- The keybinding uses `launch --type=overlay --cwd=current` so the overlay inherits the triggering window's working directory and `ctrl-p` searches from the correct project root.
- Kitty does not set a `KITTY_PARENT_WINDOW_ID` env var for overlays. The parent is discovered via `kitty-remote ls`, which exposes an `overlay_for` field on each overlay window's JSON entry. `kitty-overlay-window-id` encapsulates this lookup using `$KITTY_WINDOW_ID` from the overlay's own environment.
- `kitty-remote` (existing wrapper) handles the Unix socket path transparently; all new scripts use it rather than calling `kitty @` directly.
- Path output from `ctrl-p` is one absolute path per line (the `fzf-postprocess` step already strips the `▮colored` segment). Multi-line output is split into an array, each element shell-quoted with `${(q-)}`, then space-joined — matching exactly the behavior of the existing ZSH `ctrl-p` widget.
- A trailing space is appended to the sent text so the cursor is immediately ready for the next token.
- Context-aware dispatch (the ZSH widget switches to `fzf-git-files-dirty-stageable` when the last buffer word is `vfa`, etc.) is out of scope: from a Kitty overlay there is no access to the parent window's buffer content, and the special-case commands are ZSH-specific workflows unlikely to be needed in other contexts.

## Testing Decisions

Good tests for `kitty-ctrl-p` verify external behavior — what gets sent to the parent window — without asserting on internal implementation details like how the parent ID was obtained. Collaborators (`kitty-overlay-window-id`, `ctrl-p`, `kitty-window-send-text`) are mocked with `bats_mock`.

Only `kitty-ctrl-p` gets tests. `kitty-overlay-window-id` and `kitty-window-send-text` are thin wrappers (jq field extraction and a single kitty-remote call respectively); their tests would only verify that wiring works, which adds no meaningful signal.

Prior art: `kitty/__tests__/kitty-tab-attention-add.bats` — same pattern of mocking a collaborator and asserting on side effects.

Test cases for `kitty-ctrl-p`:
- Single selection: correct path sent to parent window
- Multi-selection: paths shell-quoted and space-joined
- Path containing spaces: correctly quoted
- No selection (ctrl-p exits non-zero): nothing sent, script exits cleanly
- Empty output from ctrl-p: nothing sent, script exits cleanly

## Out of Scope

- Context-aware picker dispatch (switching to `fzf-git-files-dirty-stageable`, `fzf-bats-test`, etc. based on buffer content)
- NeoVim integration beyond what already works via the Kitty overlay
- Claude Code native keybinding (no custom action type API exists)
- A `kitty-window-send-text` test suite (trivial wiring)
- A `kitty-overlay-window-id` test suite (trivial jq extraction)
