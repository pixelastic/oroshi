## TLDR

Add temporary debug logging to `_on_attention_clear` and diagnose the auto-clear bug.

## What to build

This is a HITL issue. Add temporary append-only logging to `_on_attention_clear()`
in `tools/term/kitty/config/lib/redraw.py`. The log file lives at
`$OROSHI_TMP_FOLDER/kitty/attention-debug.log`.

At each key step of the callback, log:
- Timer fired (timestamp)
- `activeTabId` value
- Attention entries read from disk (`on_disk`)
- Whether `active_tab_id in on_disk`
- `subprocess.run` return code

Then use the worktree-aware Reload to deploy the logging, trigger attention on a
tab, focus it, wait, and read the log to determine root cause.

Possible failure modes:
- Timer never fires (cancelled by rapid redraws)
- `activeTabId` is wrong
- Subprocess fails silently (PATH issue in thread context)

## Acceptance criteria

- [ ] Debug logging added to `_on_attention_clear`
- [ ] Root cause of the auto-clear bug identified
- [ ] Findings documented in GUIDANCE.md Discoveries section
