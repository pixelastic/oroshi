## TLDR

Rename ZSH functions, remove --type flag, switch to tabId-per-line format.

## What to build

**File renames** (git mv):
- `kitty-tab-attention-add` → `kitty-tab-notification-add`
- `kitty-tab-attention-remove` → `kitty-tab-notification-remove`
- Their test files accordingly

**kitty-tab-notification-add**:
- Remove `zparseopts` for `--type` flag
- Remove `attentionType` variable
- Grep pattern: `^${tabId}$` instead of `^${tabId}:${attentionType}$`
- Write just `${tabId}` instead of `${tabId}:${attentionType}`
- No more `sed` to remove old entry (no type replacement needed)
- Rename `attentionFile` → `notificationFile`
- Update comments

**kitty-tab-notification-remove**:
- Sed pattern: `/^${tabId}$/d` instead of `/^${tabId}:/d`
- Rename `attentionFile` → `notificationFile`
- Update comments

**Tests**: rewrite BATS tests to match new behavior (no types, bare tabId format). Remove tests that tested type-specific behavior (type replacement).

## Behavioral Tests

**kitty-tab-notification-add**:
- writes tabId to notification file
- same tabId not duplicated
- triggers kitty-redraw on new entry
- does not trigger kitty-redraw when entry already exists

**kitty-tab-notification-remove**:
- removes a tab entry
- does not affect other tab IDs
- no-op when tab ID not in file
- no-op when notification file does not exist

## Acceptance criteria

- [ ] Old function files renamed via git mv
- [ ] No `--type` flag in add function
- [ ] File format is `tabId` per line (no colon)
- [ ] `bats` tests pass for both functions
- [ ] `zsh-lint` passes for both functions
- [ ] `bats-lint` passes for both test files
