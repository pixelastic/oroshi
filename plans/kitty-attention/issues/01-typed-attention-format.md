## TLDR

Change the attention file format from bare `tabId` lines to `tabId:type` lines.

## What to build

Update the attention file format so every entry carries a type alongside the tab ID. The two valid types are `stop` (Claude finished) and `notification` (tool approval pending).

- `kitty-tab-attention-add` gains a `--type` flag (default: `stop`). It writes `tabId:type` to the attention file. The idempotency check matches on tab ID only (ignores the type suffix), so re-adding the same tab with a different type replaces the existing entry rather than duplicating it.
- `kitty-tab-attention-remove` updates its `sed` pattern to match `^tabId:` (prefix) instead of `^tabId$` (exact).
- `redraw.py` parses `tabId:type` pairs and populates `tabState["attentionIds"]` as a `dict` (`{tabId: type}`) instead of a `set`.
- `state.py` initialises `attentionIds` as `{}` instead of `set()`.

All existing callers of `kitty-tab-attention-add` (the `stop` hook) pass no `--type` flag and continue to work via the default.

## Behavioral Tests

**kitty-tab-attention-add**
- Writing with no `--type` flag stores `tabId:stop` in the attention file
- Writing with `--type notification` stores `tabId:notification` in the attention file
- Adding the same tab ID a second time does not create a duplicate entry
- Adding a tab ID that already exists with a different type replaces the entry
- `kitty-redraw` is called after a new entry is written
- `kitty-redraw` is not called when the entry already exists

**kitty-tab-attention-remove**
- Removes a `tabId:stop` entry from the file
- Removes a `tabId:notification` entry from the file
- Does not affect other tab IDs
- No-op when the tab ID is not in the file
- No-op when the attention file does not exist

**redraw.check()**
- Parses `tabId:type` lines into a `{tabId: type}` dict
- Ignores blank lines
- Sets `attentionIds` to empty dict when attention file is absent

## Acceptance criteria

- [ ] `kitty-tab-attention-add 42` writes `42:stop` to the attention file
- [ ] `kitty-tab-attention-add 42 --type notification` writes `42:notification`
- [ ] `kitty-tab-attention-remove 42` removes any `42:*` entry
- [ ] `redraw.check()` populates `attentionIds` as a dict
- [ ] All existing bats tests updated and passing
- [ ] `test_redraw.py` updated and passing
