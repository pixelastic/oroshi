## Problem Statement

When a Claude session finishes responding in a background Kitty tab, there is no
visual indicator on that tab. The only signal is audio, which can be missed or
disabled. The user has no way to know at a glance which tabs need their attention.

## Solution

Display an attention icon on a Kitty tab when Claude finishes responding in that
tab while it is inactive. The icon disappears when the user sends their next
message to Claude in that tab — confirming they have seen and are engaging with
the response. Navigation between tabs (passing through intermediate tabs) does
not clear the indicator.

## User Stories

1. As a user with multiple Kitty tabs running Claude sessions, I want a visual
   indicator on background tabs when Claude finishes, so that I know which tabs
   need my attention without relying on audio.
2. As a user, I want the attention indicator to appear only when the tab is
   inactive (not my current focus), so that it is not shown when I am already
   looking at the response.
3. As a user, I want the attention indicator to disappear when I reply to Claude
   in that tab, so that acknowledged sessions no longer show the indicator.
4. As a user, I want navigating through intermediate tabs (without interacting
   with Claude in them) to not clear their attention indicators, so that
   indicators reflect intent rather than accidental focus.
5. As a user with sound disabled, I want the attention indicator to still appear,
   so that the visual signal is independent of audio preferences.
6. As a user, I want subagent completions to not trigger the attention indicator,
   so that only top-level Claude responses produce notifications.
7. As a user running Claude outside of Kitty, I want Claude hooks to remain
   functional, so that non-Kitty environments are not broken.
8. As a user, I want the attention icon to appear before the fullscreen indicator
   (when both are active), so that the tab bar layout is consistent.

## Implementation Decisions

### Attention state storage

Attention state is stored in a plain text file on disk — one tab ID per line.
This file is read by the Kitty tab bar Python module on each render. The
mechanism follows the existing beacon pattern already in use for tab bar
refreshes.

### Add trigger — Stop hook

The existing `stop` hook is restructured so that attention logic runs
independently of sound logic. New execution order:

1. Read stdin (always, needed for transcript path)
2. Skip if subagent (transcript path contains `/subagents/`)
3. If `KITTY_WINDOW_ID` is set: resolve tab ID, add attention if tab is inactive
4. Skip if sound disabled (early exit for sound only, from here down)
5. Audio logic

If `KITTY_WINDOW_ID` is absent (Claude running outside Kitty), the attention
step is skipped silently.

### Remove trigger — UserPromptSubmit hook

A new `userPromptSubmit` hook script calls `kitty-tab-attention-remove` for the
current tab. This fires when the user sends a message to Claude, which is the
moment the attention is considered acknowledged. The hook is declared in the
Claude settings file (tracked in the oroshi repo, not modified via the symlink).

### Tab ID resolution

The stop hook uses `KITTY_WINDOW_ID` (available in interactive sessions) to
resolve the tab ID via `kitty-window-tab-id`. The `kitty-tab-focused` script
then checks whether that tab is currently active before deciding to add attention.

### Attention file bug fix

`kitty-tab-attention-add` currently exits early if the attention file does not
exist. The fix creates the file and its parent directory if absent, then
proceeds normally.

### Tab bar rendering

`parseRawTabData.py` is extended to:
- Load `dist/icons.json` once at module level (cached), replacing all inlined
  glyphs in the file.
- Read the attention file on each render to get the current set of attention tab
  IDs.
- Append the attention icon as a suffix to the tab title, placed before the
  fullscreen icon when both are active.

### Icons

Two icons are added to `src/icons.jsonc` and rebuilt into `dist/icons.json` and
`dist/icons.zsh`:
- `kitty-tab-attention` — the message icon displayed on tabs needing attention
- `kitty-tab-fullscreen` — the fullscreen icon currently inlined in Python,
  migrated to the icons system

### Immediate tab bar redraw

After writing to the attention file, the scripts trigger an immediate tab bar
redraw by calling `kitty @ set-tab-color --match "id:<tabId>" active_bg=NONE`.
This command has no visual effect (NONE reverts to default) but internally calls
`mark_tab_bar_dirty()` in the Kitty source, scheduling a render on the next
frame. The icon therefore appears with negligible latency — no polling involved.

This replaces the `kitty-refresh` beacon call in both attention scripts for the
attention use case. The existing 5-second beacon remains in place for other
purposes (project color reloads, statusbar updates).

## Testing Decisions

Good tests verify observable behavior through the public interface only — they
do not assert on internal file structure or implementation choices.

Bats tests are written for the two attention scripts:

- `kitty-tab-attention-add`: tests that calling the script adds the tab ID to the
  attention file, is idempotent (calling twice does not duplicate), and creates
  the file if it does not exist. Prior art: other bats tests in
  `scripts/bin/kitty/__tests__/`.
- `kitty-tab-attention-remove`: tests that calling the script removes the tab ID
  from the attention file, is a no-op if the file does not exist, and does not
  affect other tab IDs in the file.

No tests are written for the `stop` or `userPromptSubmit` hooks (hooks are glue
code with live dependencies on Kitty and the Claude environment). No tests are
written for Python tab bar changes (no Python test framework in this repo).

## Out of Scope

- Showing different icons for fast vs. slow Claude responses (the audio already
  distinguishes these; the visual indicator is binary).
- Per-tab variable storage via `kitty @ set-user-vars` as an alternative to the
  file-based approach.
- Showing different icons for fast vs. slow Claude responses (the audio already
  distinguishes these; the visual indicator is binary).
- Clearing the attention indicator on tab focus rather than on user reply.
- NeoVim integration for the icons system.

## Further Notes

The attention file lives in `$OROSHI_TMP_FOLDER/kitty/attention`. It is not
cleaned up on Kitty restart. If stale tab IDs accumulate (from closed tabs),
they have no visible effect since the tab bar only renders currently-open tabs.
