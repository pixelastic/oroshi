## Problem Statement

After `mic2txt` transcribes speech, `focus-insert` pastes the text via
Ctrl+Shift+V then restores the previous clipboard after 1 second. If the paste
fails (focus lost, app doesn't support Ctrl+Shift+V, timing issue), the
transcription is gone with no way to recover it.

## Solution

Persist the last transcription to a file and provide a global keybinding
(Ctrl+Alt+V) that re-pastes it into the focused window, acting as a "replay
last dictation" shortcut.

## User Stories

1. As a user, I want my last transcription saved to disk, so that a failed paste doesn't lose my text
2. As a user, I want to press Ctrl+Alt+V to re-paste the last transcription, so that I can retry when a paste fails
3. As a user, I want the replay to paste into the currently focused window (not just clipboard), so that I get the same behavior as the original paste
4. As a user, I want the replay keybinding to do nothing silently when no transcription exists, so that accidental presses don't produce errors
5. As a user, I want both the initial paste and the replay to go through the same code path, so that behavior is consistent

## Implementation Decisions

- **Transcription file**: Written to `/dev/shm/oroshi/mic2txt/transcription.txt`
  (RAM-backed, lost on reboot — acceptable since stale transcriptions aren't
  useful across sessions)
- **New script `mic2txt-paste`**: Reads the transcription file, guards on file
  missing (exit silently), calls `focus-insert` with the content
- **`mic2txt-raw` refactor**: After all transformations, writes transcription to
  file, then calls `mic2txt-paste` instead of `focus-insert` directly. Both the
  initial paste and manual replay go through the same `mic2txt-paste` entry
  point
- **Autosubmit stays in `mic2txt-raw`**: The Enter key simulation after paste is
  a recording-session concern, not a replay concern
- **Keybinding**: `<Ctrl><Alt>V` → `mic2txt-paste`, added as a GNOME custom
  keybinding in the Ubuntu 24.04 keybinding config

## Testing Decisions

- Only `mic2txt-paste` gets tests — the other changes are config/wiring
- Tests should mock `focus-insert` (collaborator mock via `bats_mock`) and
  exercise: file present → calls focus-insert with content, file missing → exits
  silently without calling focus-insert
- Prior art: `scripts/bin/audio/__tests__/mic2txt-cancel.bats` — same pattern
  of mocking collaborators and checking file state in `/dev/shm/oroshi/mic2txt/`

## Out of Scope

- Notification or sound feedback on paste success/failure
- Clipboard-only mode (no auto-paste)
- History of multiple transcriptions (only last one is saved)
- Re-targeting paste to a specific window (kitty-remote etc.)
