## Problem Statement

The kitty tab bar attention icon system — used to signal when Claude has finished or needs approval — has several correctness and usability gaps: the icon appears in the wrong position relative to the fullscreen icon, stale attention entries persist after a tab closes or Claude exits, and there is no visual distinction between a completed response and a pending tool approval.

## Solution

Fix icon ordering, add automatic cleanup of stale attention entries via three mechanisms (process exit, tab close, and focused-tab timer), and introduce a typed attention system with distinct icons for `stop` and `notification` events.

## User Stories

1. As a user, I want the attention icon to appear after the fullscreen icon in the tab title, so that the tab bar layout is visually consistent.
2. As a user, I want the attention icon cleared when I close the Claude process, so that tabs don't show stale attention after Claude exits.
3. As a user, I want the attention icon cleared when a closed tab's ID is reused by a new tab, so that new tabs don't inherit stale attention state.
4. As a user, I want the attention icon cleared automatically after I stay on the tab for ~3 seconds, so that I don't have to manually dismiss it.
5. As a user, I want the 3-second timer reset each time a render fires while the tab has attention, so that quickly cycling through tabs does not prematurely clear attention.
6. As a user, I want a distinct icon when Claude is waiting for tool approval, so that I can tell at a glance whether Claude finished or needs my authorization.
7. As a user, I want the approval attention icon to follow the same focus rules as the stop icon (not shown if tab is already focused), so that the behavior is consistent.
8. As a user, I want the attention icon cleared when I submit a prompt in Claude, so that the icon disappears as soon as I start interacting (existing behavior, preserved).

## Implementation Decisions

### Attention file format change
The attention file changes from bare tab IDs (`tabId\n`) to a typed format (`tabId:type\n`). The two types are `stop` (Claude finished) and `notification` (tool approval pending). `kitty-tab-attention-add` gains a `--type` flag defaulting to `stop`.

### `kitty-tab-attention-remove` pattern update
The `sed` removal pattern is updated from an exact `^tabId$` match to `^tabId:` prefix match, to handle the new typed format.

### `attentionIds` becomes a dict
`tabState["attentionIds"]` changes from a `set` of tab ID strings to a `dict` mapping tab ID string → type string. All consumers (`tab_data`, `redraw`, `second_pass`) are updated accordingly.

### Icon order fix
In the tab title builder, the fullscreen icon is appended before the attention icon (previously reversed).

### Icon type selection
`tab_data` reads the attention type from `attentionIds[str(id)]` and selects between `kitty-tab-attention` (type `stop`) and `kitty-tab-attention-notification` (type `notification`). A placeholder glyph is used for `kitty-tab-attention-notification` in `icons.jsonc`; the user will replace it with the final glyph.

### Clear on close — claude wrapper
The `claude` binary wrapper calls `kitty-tab-attention-remove` (for the current window's tab) unconditionally after the claude process exits.

### Clear on tab close — stale ID pruning in second_pass
At the end of each render cycle (`is_last=True`), `second_pass` calls a new `redraw.cleanup(live_tab_ids)` function. This compares the keys of `attentionIds` against the set of live tab IDs; any stale entries are removed from the attention file. The cleanup only writes to disk when stale entries are actually found.

### `activeTabId` in tabState
A new `activeTabId` key (initially `None`) is updated on every render cycle to track the currently focused tab.

### Clear on focus — 3-second timer in second_pass
At the end of each render cycle, if the active tab has attention:
- Any existing `threading.Timer` is cancelled.
- A new `threading.Timer(3.0, callback)` is started.

Only one timer can be live at a time. The callback reads `tabState["activeTabId"]`, checks if that tab ID is still in `attentionIds`, and if so removes it from the attention file and triggers a redraw. The timer thread only performs file I/O and does not call kitty Python APIs.

### Notification hook update
The `notification` hook gains a focus check (same as the `stop` hook: skip if the tab is currently focused) and calls `kitty-tab-attention-add --type notification`.

### No clear-on-typing
Kitty has no passive key-press hook, and Claude Code keybindings cannot execute shell commands. Clear-on-typing is not implemented; the existing `UserPromptSubmit` hook (which clears on submit) remains the earliest clearing point.

## Testing Decisions

Good tests verify observable external behavior — what enters and exits the attention file, which icons appear in the rendered title, which scripts are called and when — without asserting on internal implementation details.

### Python tests (pytest)
- **`test_redraw.py`** — updated for the `tabId:type` parse format; new tests for `cleanup(live_tab_ids)`: stale IDs removed from file, live IDs preserved, no write when nothing is stale. Prior art: existing `test_redraw.py`.
- **`test_tab_data.py`** — new tests: attention icon appears after fullscreen icon; `stop` type renders `kitty-tab-attention`; `notification` type renders `kitty-tab-attention-notification`. Prior art: existing `test_tab_data.py`.
- **`test_tabs_second_pass.py`** — new tests: `cleanup` called at `is_last`; `activeTabId` updated each render; timer cancelled and recreated when active tab has attention; timer not started when active tab has no attention. Prior art: existing `test_tabs_second_pass.py`.

### ZSH tests (bats)
- **`kitty-tab-attention-add.bats`** — updated: default type is `stop`; `--type notification` writes correct format; dedup check matches on tab ID regardless of type. Prior art: existing `kitty-tab-attention-add.bats`.
- **`kitty-tab-attention-remove.bats`** — updated: removes entry matching `tabId:*` format. Prior art: existing `kitty-tab-attention-remove.bats`.

## Out of Scope

- Clear-on-typing: no mechanism exists in kitty or Claude Code to detect first keystroke without explicit per-key bindings.
- Final glyph for the notification attention icon: the placeholder in `icons.jsonc` will be replaced by the user manually.
- Any changes to the `stop` hook itself: its existing behavior (focus check + `kitty-tab-attention-add`) is preserved as-is, with only the underlying format of the attention file changing transparently.
