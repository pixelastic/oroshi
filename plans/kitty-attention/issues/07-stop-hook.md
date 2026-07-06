## TLDR

Restructure the `stop` hook to run Attention logic independently of sound logic.

## What to build

Restructure `tools/ai/claude/config/hooks/stop` so that Attention state is
set regardless of whether sound is enabled or disabled.

New execution order:
1. Read stdin (always — needed for transcript path)
2. Skip entirely if subagent (transcript path contains `/subagents/`)
3. If `KITTY_WINDOW_ID` is set: resolve Tab ID via `kitty-window-tab-id`,
   call `kitty-tab-attention-add` only if the tab is not currently focused
4. If sound is disabled: exit (sound-only early exit, does not affect Attention)
5. Audio logic (unchanged)

If `KITTY_WINDOW_ID` is absent (Claude running outside Kitty), step 3 is
skipped silently — no error, no output.

## Acceptance criteria

- [ ] Attention is added when Claude finishes in an inactive tab, even when sound is disabled
- [ ] Attention is not added for subagent completions
- [ ] Attention is not added when the tab is currently focused
- [ ] Attention is not added when `KITTY_WINDOW_ID` is absent
- [ ] Sound logic is unchanged
- [ ] Hook linted with `zsh-lint`
