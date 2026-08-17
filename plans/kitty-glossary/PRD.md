## Problem Statement

The Kitty tab bar codebase uses "attention" vocabulary (attentionIds, attentionIcon, kitty-tab-attention-add, etc.) with two subtypes (stop, notification) that have no meaningful distinction. The GLOSSARY.md was updated to unify everything under the "notification" family — Notify, Notification Marker, Notification Tab List — but the code still uses the old terms and the now-unnecessary two-type system.

## Solution

Rename all "attention" vocabulary in the codebase to match the glossary's "notification" family. Merge the two attention subtypes into a single Notification Marker. Simplify the data model: the Notification Tab List file stores one tabId per line (no more `tabId:type`), and the in-memory state becomes a set instead of a dict.

## User Stories

1. As a developer reading the codebase, I want variable names and function names to match the GLOSSARY.md terms, so that I can reason about the code using a single consistent vocabulary.
2. As a developer calling `kitty-tab-notification-add`, I want a simple `kitty-tab-notification-add <tabId>` interface without a `--type` flag, so that the API reflects the single-marker design.
3. As a user with multiple Kitty tabs, I want the tab bar to keep working during the rename, so that no intermediate commit breaks my live environment.
4. As a developer maintaining the Python renderer, I want `notificationIds` to be a set of tab ID strings, so that the data model reflects the absence of subtypes.
5. As a developer editing icons, I want a single `tab-notification` icon key, so that the icon configuration matches the single-marker design.
6. As a developer working on hooks, I want `stop` and `notification` hooks to call `kitty-tab-notification-add` without `--type`, so that the hooks use the new API.
7. As a future developer, I want the transitional compatibility code (split on `:` and keep only the tabId) to be explicitly marked for removal, so that it doesn't become permanent technical debt.

## Implementation Decisions

- **Icon key**: merge `tab-attention-stop` and `tab-attention-notification` into a single `tab-notification` key using the bell glyph (from the old notification icon).
- **Python state**: `attentionIds` (dict mapping tabId→type) becomes `notificationIds` (set of tabId strings).
- **File format**: the Notification Tab List transitions from `tabId:type` per line to `tabId` per line.
- **Transitional compatibility**: the Python parser splits on `:` and keeps only the first part (tabId). This handles both old-format (`42:stop`) and new-format (`42`) lines. This code is explicitly marked for removal in a later cleanup issue.
- **Ordering**: icons first (add new key alongside old), then Python (consume both formats), then ZSH functions (switch to new format), then hooks (use new function name), then cleanup (remove old icon keys and compat code).
- **File renames**: `kitty-tab-attention-add` → `kitty-tab-notification-add`, `kitty-tab-attention-remove` → `kitty-tab-notification-remove` (git mv).

## Testing Decisions

- **Python tests** (`python-test`): test that the renderer parses both old and new file formats, test the set-based notificationIds, test the single icon lookup. Prior art: existing `test_redraw.py`, `test_tab_data.py`.
- **BATS tests** (`bats`): test the simplified ZSH functions (no `--type` flag, `tabId` per line format). Prior art: existing `kitty-tab-attention-add.bats`, `kitty-tab-attention-remove.bats`.
- **Hook BATS tests**: test that hooks call `kitty-tab-notification-add` without `--type`. Prior art: existing `notification.bats`, `stop.bats`.
- Good test = tests external behavior (file written, state produced), not internal implementation details.

## Out of Scope

- Renaming the on-disk file path (`$OROSHI_TMP_FOLDER/kitty/attention`) — the glossary documents it as-is.
- Adding Status Marker or Fullscreen Marker to the glossary code — those are separate future features.
- Renaming the lint test fixture in `rule-no-chained-and.bats` that happens to use `attentionFile` as an example string.

## Further Notes

- The `test_tabs_second_pass.py` and `test_pick_tabs.py` have pre-existing failures unrelated to this rename (missing `draw_statusbar` and `get_statusbar_width` attributes). These are not in scope.
- The GLOSSARY.md is already updated on this branch — only code changes remain.
