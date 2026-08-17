## TLDR

Rename Python attention vocabulary to notification, merge subtypes into single marker, add transitional compat for old file format.

## What to build

Rename across 4 Python source files + their tests:

**state.py**: `attentionIds` (dict) → `notificationIds` (set). Update comment.

**redraw.py**:
- `ATTENTION_FILE` → `NOTIFICATION_FILE` (same path on disk)
- `clear_attention` → `clear_notification`
- `_read_attention_entries` → `_read_notification_entries`
- `_remove_attention_entries` → `_remove_notification_entries`
- Parser: split each line on `:` and keep only the first part (tabId). This handles both `42:stop` (old) and `42` (new). Mark with a `# COMPAT: remove when ZSH functions no longer write tabId:type` comment.
- Build a set instead of a dict.

**tab_data.py**:
- `isAttention` → `isNotification`
- `attentionIcon` → `notificationMarker`
- Remove `attentionType` lookup — use single key `kitty-tab-notification` directly.
- Update the dict key from `attentionIcon` to `notificationMarker`.

**tabs_second_pass.py**:
- `tab_item["attentionIcon"]` → `tab_item["notificationMarker"]`
- Update comment.

**Tests**: update all 5 test files to use new variable names, set-based state, single icon key. Tests for the compat parser: verify both `42:stop` and `42` lines produce the same set entry.

## Behavioral Tests

**redraw.check()**:
- parses old-format lines (`42:stop`) into set `{"42"}`
- parses new-format lines (`42`) into set `{"42"}`
- parses mixed-format lines into correct set
- blank lines ignored

**redraw.clear_notification()**:
- removes tab from notification file and memory
- keeps other tabs

**tab_data.build_tab_data()**:
- notification marker uses `kitty-tab-notification` icon key
- no notification marker when tab not in notificationIds

## Acceptance criteria

- [ ] All Python source files use notification vocabulary
- [ ] `notificationIds` is a set, not a dict
- [ ] Parser handles both `tabId:type` and `tabId` line formats
- [ ] Compat code marked with `# COMPAT:` comment
- [ ] `python-test` passes for all changed test files
- [ ] `python-lint` passes for all changed source files
