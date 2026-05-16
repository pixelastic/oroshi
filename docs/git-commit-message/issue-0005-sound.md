## PRD

docs/git-commit-message/PRD.md

## What to build

Add async fire-and-forget sound playback at the end of a successful run. The
script must return (and Neovim must receive the message) without waiting for
the audio process to finish.

Implementation: `child_process.spawn` with `detached: true` and
`stdio: 'ignore'`, followed by `.unref()`.

Sound file: `git-commit-message.mp3` played via `audio-play-oroshi`.

## Acceptance criteria

- [ ] `audio-play-oroshi git-commit-message.mp3` is triggered on success
- [ ] The script exits and returns output to stdout before the sound finishes playing
- [ ] No sound is played on error paths

## Blocked by

- issue-0003-script-core.md
