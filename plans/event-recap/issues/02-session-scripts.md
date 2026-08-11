## TLDR

Create `meetup-recap-start` and `meetup-recap-tick` session scripts.

## What to build

Create two ZSH scripts in `scripts/bin/ai/meetup-recap/`:

**`meetup-recap-start`** — Initialize a meetup-recap session.
- Create session directory at `/tmp/oroshi/claude/meetup-recap/`
- Generate a UUID-based draft filepath
- Output JSON: `{"draftPath": "/tmp/oroshi/claude/meetup-recap/<uuid>.md"}`
- Same pattern as `slack-writer-start`

**`meetup-recap-tick`** — Copy current draft to clipboard.
- Takes `draftPath` as argument
- Validates file exists
- Copies content to clipboard via `clipboard-write`
- Same pattern as `slack-writer-end` but named to reflect it's called at every loop iteration

## Behavioral Tests

**meetup-recap-start:**
- Outputs valid JSON with a `draftPath` key
- `draftPath` points to a `.md` file under `/tmp/oroshi/claude/meetup-recap/`
- Session directory is created if it doesn't exist

**meetup-recap-tick:**
- Fails with error if no argument given
- Fails with error if file doesn't exist
- Calls `clipboard-write` with the file content

## Acceptance criteria

- [ ] `meetup-recap-start` outputs valid JSON with `draftPath`
- [ ] `meetup-recap-tick <path>` copies file content to clipboard
- [ ] `meetup-recap-tick` without argument prints usage to stderr and exits 1
- [ ] `meetup-recap-tick` with nonexistent file prints error to stderr and exits 1
- [ ] Both scripts pass `zsh-lint`
- [ ] Bats tests pass
