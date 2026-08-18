## TLDR

Rename on-disk file path from `kitty/attention` to `kitty/notification`.

## What to build

**Path change**: `$OROSHI_TMP_FOLDER/kitty/attention` → `$OROSHI_TMP_FOLDER/kitty/notification`

**redraw.py**: change `NOTIFICATION_FILE` value from `".../kitty/attention"` to `".../kitty/notification"`.

**kitty-tab-notification-add**: change path in `notificationFile` assignment.

**kitty-tab-notification-remove**: change path in `notificationFile` assignment.

**BATS tests**: update all `$BATS_TMP_DIR/kitty/attention` references to `$BATS_TMP_DIR/kitty/notification`.

**GLOSSARY.md**: update the Notification Tab List entry to reference the new path.

**Python tests**: update any hardcoded `kitty/attention` path references.

## Behavioral Tests

**kitty-tab-notification-add**:
- writes tabId to `kitty/notification` file (not `kitty/attention`)

**kitty-tab-notification-remove**:
- removes tabId from `kitty/notification` file (not `kitty/attention`)

## Acceptance criteria

- [ ] No remaining references to `kitty/attention` in source or test files (plan files excluded)
- [ ] `bats` tests pass for both ZSH functions
- [ ] `python-test` passes for redraw
- [ ] `zsh-lint` passes for both ZSH functions
- [ ] GLOSSARY.md updated
