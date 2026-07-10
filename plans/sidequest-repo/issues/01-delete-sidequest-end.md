## TLDR

Remove the `sidequest-end` script, its tests, and its allowlist entry.

## What to build

Delete the `sidequest-end` script and its bats test file entirely. In `allowlist.json`, replace the `"sidequest-end"` entry with `"sidequest"`.

No new behavior is introduced — this is pure cleanup to remove the layer that `sidequest-end` added between the skill and the underlying `sidequest` script.

## Scaffolding Tests

Verify that `sidequest-end` no longer exists on disk and that `allowlist.json` no longer contains `"sidequest-end"`.

## Acceptance criteria

- [ ] `scripts/bin/ai/sidequest/sidequest-end` is deleted
- [ ] `scripts/bin/ai/sidequest/__tests__/sidequest-end.bats` is deleted
- [ ] `tools/ai/claude/config/hooks/allowlist.json` no longer contains `"sidequest-end"`
- [ ] `tools/ai/claude/config/hooks/allowlist.json` contains `"sidequest"`
