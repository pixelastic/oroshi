## Problem Statement

The speech-to-text toggle (`mic2txt-raw`) has no safety guards. Accidental double-taps on the record key create recordings too short for the transcription API, causing errors. Long recordings cannot be aborted — they always get sent for transcription, wasting time and API calls.

## Solution

Add two cancel mechanisms that share the same code path:

1. **Min-duration guard**: if the recording is stopped within 2 seconds of starting, cancel automatically instead of transcribing.
2. **Manual cancel keybinding**: a new shortcut (Shift+Ctrl+RightShift) that cancels any in-progress recording on demand.

Both paths call the same `mic2txt-cancel` script, which kills the recorder, cleans up temp files, and plays a cancel sound.

## User Stories

1. As a user, I want accidental double-taps on the record key to be silently caught, so that I don't get API errors from sub-2-second recordings.
2. As a user, I want the double-tap guard to play a cancel sound, so that I know the accidental recording was caught and discarded.
3. As a user, I want a keybinding to cancel an in-progress recording, so that I can abort a long recording I no longer need.
4. As a user, I want the cancel keybinding to kill the `rec` process and clean up all temp files (PID, timestamp, wav), so that no stale state is left behind.
5. As a user, I want the cancel keybinding to play a distinct sound, so that I get audio confirmation the recording was discarded.
6. As a user, I want the cancel keybinding to do nothing if no recording is in progress, so that accidental presses are harmless.
7. As a user, I want both cancel paths (double-tap and manual) to behave identically, so that the behavior is predictable regardless of how I cancel.
8. As a user, I want no API call or transcription to happen on cancel, so that I don't waste time or API quota.

## Implementation Decisions

### Module: `mic2txt-cancel` (new script)

Deep module encapsulating all cancel logic:
- If no PID file exists, exit silently (nothing to cancel)
- Kill the `rec` process via `kill-pid`
- Remove PID file, timestamp file, and wav file
- Play the cancel sound via `audio-play-oroshi`

### Module: `mic2txt-raw` (modification)

- On start: save `$EPOCHREALTIME` to a `START_TIME` file alongside the PID file (sub-second precision to avoid boundary-rounding issues with `$EPOCHSECONDS`)
- On stop: read `START_TIME`, compute elapsed time. If < 2 seconds, call `mic2txt-cancel` and return early. Otherwise proceed with normal transcription flow.
- The `START_TIME` check happens before the existing `sleep 2` in `stopRecording`.

### Module: keybinding config (modification)

- New entry: `<Shift><Ctrl>XF86Launch5` mapped to `mic2txt-cancel`
- Mnemonic: same as record (Ctrl+RightShift), just add Shift to mean "cancel"

### Module: cancel sound (new symlink)

- `mic2txt-cancel.mp3` symlinked to an existing sound that conveys "abort/dismiss"

## Testing Decisions

Good tests verify external behavior (files created/removed, processes killed, commands invoked) without testing implementation details like internal variable values.

### `mic2txt-cancel` tests (bats)

- Verify `kill-pid` is called with the PID from the PID file
- Verify all temp files (PID, START_TIME, wav) are cleaned up after cancel
- Verify cancel sound is played
- Verify no-op when no PID file exists (no recording in progress)
- Use `bats_mock` to stub `kill-pid` and `audio-play-oroshi`

### `mic2txt-raw` tests (bats)

- Verify that stopping a recording with elapsed < 2s calls `mic2txt-cancel`
- Verify that stopping a recording with elapsed >= 2s proceeds with normal transcription (does not call `mic2txt-cancel`)
- Verify `START_TIME` file is created on start
- Use `bats_mock` to stub `rec`, `mic2txt-cancel`, and transcription commands

### Prior art

- `scripts/bin/audio/__tests__/wav2txt-openai.bats` — existing audio test using `bats_load_library 'helper'` and `sourcePrefix` pattern

## Out of Scope

- Changing the XKB mapping (RightShift → XF86Launch5 stays as-is)
- Adding `notify-send` visual notifications (feedback is audio-only, consistent with the rest of the codebase)
- Configurable min-duration threshold (hardcoded 2 seconds is sufficient)
- Cleanup of the commented-out ffmpeg block in `mic2txt-raw`
