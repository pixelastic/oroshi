## TLDR

New `mic2txt-cancel` script that kills a recording, cleans up temp files, and plays a cancel sound.

## What to build

Create a new `scripts/bin/audio/mic2txt-cancel` script and a `mic2txt-cancel.mp3` sound symlink.

The script encapsulates all cancel logic — it is the single code path for both accidental double-taps and manual cancellation:

- If no PID file exists in `/dev/shm/oroshi/mic2txt/`, exit silently (nothing to cancel)
- Kill the `rec` process via `kill-pid` using the PID from the PID file
- Remove: PID file, START_TIME file, and wav recording file
- Play `mic2txt-cancel.mp3` via `audio-play-oroshi`

The cancel sound symlink goes in `tools/audio/sounds/config/mic2txt-cancel.mp3`, pointing to an existing sound that conveys "abort/dismiss."

## Behavioral Tests

**Scenario: recording in progress**
- calling mic2txt-cancel kills the rec process via kill-pid with the correct PID
- calling mic2txt-cancel removes the PID file
- calling mic2txt-cancel removes the START_TIME file
- calling mic2txt-cancel removes the wav file
- calling mic2txt-cancel plays the cancel sound

**Scenario: no recording in progress**
- calling mic2txt-cancel when no PID file exists exits without error
- calling mic2txt-cancel when no PID file exists does not call kill-pid
- calling mic2txt-cancel when no PID file exists does not play any sound

## Acceptance criteria

- [ ] `mic2txt-cancel` script created and executable
- [ ] `mic2txt-cancel.mp3` symlink created in sounds config
- [ ] All temp files cleaned up on cancel (PID, START_TIME, wav)
- [ ] `rec` process killed via `kill-pid`
- [ ] Cancel sound played via `audio-play-oroshi`
- [ ] No-op when no recording is in progress
- [ ] All behavioral tests pass
