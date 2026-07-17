## TLDR

Create `kitty-pwd` script to return the cwd of the active window in the focused tab.

## What to build

Add a new shell script `scripts/bin/kitty/kitty-pwd` that calls
`kitty @ ls --match-tab state:focused` and pipes the JSON through `jq` to
extract the cwd of the focused window. The script takes no arguments and prints
the cwd to stdout.

## Behavioral Tests

**Parsing kitty ls JSON output:**
- returns cwd of the focused window when tab has one window
- returns cwd of the focused window when tab has multiple windows
- returns empty and fails when no focused window found

## Acceptance criteria

- [ ] `kitty-pwd` prints the cwd of the focused window in the focused tab
- [ ] Bats tests mock `kitty @ ls` output and verify jq parsing
