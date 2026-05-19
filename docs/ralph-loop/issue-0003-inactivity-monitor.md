## PRD

[ralph --max loop](./PRD.md)

## What to build

Add an inactivity monitor to the `ralph --max` loop. Each iteration starts a background job that watches the git root for filesystem events using `inotifywait` with a 10-minute timeout. If no events occur in that window while Claude is still running, `audio-play-oroshi ralph-timeout.mp3` is played once. The alert resets if activity resumes (so it can fire again after another 10 quiet minutes).

The monitor runs in the same background job lifecycle as the sentinel watcher: started before `fg %claude`, killed with its process group when Claude exits.

## Acceptance criteria

- [ ] When `inotifywait` times out (no repo activity for 10 min) while Claude is running, `audio-play-oroshi ralph-timeout.mp3` is called once
- [ ] The alert fires only once per idle period — repeated timeouts without intervening activity do not play the sound again
- [ ] When `inotifywait` detects activity (exit code 0), the idle flag resets — a subsequent 10-min silence triggers the alert again
- [ ] When Claude exits, the inactivity monitor process and its `inotifywait` child are terminated
- [ ] When `--max` is not passed (single-run mode), no inactivity monitor is started
- [ ] All bats tests pass (using stubbed `inotifywait` and `audio-play-oroshi`)

## Blocked by

- [issue-0002](./issue-0002-loop-core.md) — monitor plugs into the loop lifecycle established in issue-0002
