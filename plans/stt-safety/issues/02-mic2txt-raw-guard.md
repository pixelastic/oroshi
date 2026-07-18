## TLDR

Add timestamp tracking and min-duration guard to `mic2txt-raw` — recordings < 2s trigger `mic2txt-cancel`.

## What to build

Modify `scripts/bin/audio/mic2txt-raw` to:

**On start (1st press):**
- Save `$EPOCHREALTIME` to a `START_TIME` file in the tmp folder, alongside the PID file

**On stop (2nd press), before the existing `sleep 2`:**
- Read `START_TIME`, compute elapsed time
- If elapsed < 2 seconds, call `mic2txt-cancel` and return early (no transcription, no API call)
- If elapsed >= 2 seconds, proceed with normal `stopRecording` flow

Uses `$EPOCHREALTIME` (sub-second precision) to avoid boundary-rounding issues.

## Behavioral Tests

**Scenario: starting a recording**
- calling mic2txt-raw when no PID file exists creates a START_TIME file

**Scenario: stopping with elapsed < 2 seconds**
- calling mic2txt-raw when elapsed < 2s calls mic2txt-cancel
- calling mic2txt-raw when elapsed < 2s does not call the transcription binary

**Scenario: stopping with elapsed >= 2 seconds**
- calling mic2txt-raw when elapsed >= 2s does not call mic2txt-cancel
- calling mic2txt-raw when elapsed >= 2s proceeds with transcription

## Acceptance criteria

- [ ] START_TIME file created on recording start with $EPOCHREALTIME value
- [ ] Recordings < 2s trigger mic2txt-cancel instead of transcription
- [ ] Recordings >= 2s proceed normally
- [ ] Elapsed check happens before the existing `sleep 2`
- [ ] All behavioral tests pass
