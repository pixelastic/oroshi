## TLDR

Update hooks and allow-list to use `kitty-tab-notification-add` without `--type`.

## What to build

**hooks/stop**:
- `kitty-tab-attention-add "$tabId" --type stop` → `kitty-tab-notification-add "$tabId"`
- Update comment from "attention" to "notification"

**hooks/notification**:
- `kitty-tab-attention-add "$tabId" --type notification` → `kitty-tab-notification-add "$tabId"`
- Update comment from "attention" to "notification"

**hooks/allow-list.json**:
- `kitty-tab-attention-add` → `kitty-tab-notification-add`

**Hook tests**: update mocks and assertions to use new function name, verify no `--type` arg is passed.

## Behavioral Tests

**stop hook**:
- notification added when tab not focused
- notification not added for subagents
- notification not added when tab is focused

**notification hook**:
- notification added when tab not focused (args = just tabId, no --type)
- notification not added when tab is focused

## Acceptance criteria

- [ ] Both hooks call `kitty-tab-notification-add` without `--type`
- [ ] Comments updated to use "notification" vocabulary
- [ ] `allow-list.json` entry renamed
- [ ] `bats` tests pass for both hook test files
- [ ] `bats-lint` passes for both hook test files
