## TLDR

Fix the Attention Icon auto-clear bug based on the diagnosis from issue 05.

## What to build

Scope depends on the root cause identified in issue 05. Apply the fix, remove the
temporary debug logging, and verify the Attention Icon disappears ~2 seconds after
focusing a tab with Attention.

## Acceptance criteria

- [ ] Attention Icon disappears ~2 seconds after focusing a tab with Attention
- [ ] Debug logging removed from `_on_attention_clear`
- [ ] Debug log file path no longer referenced in the code
