## TLDR

Create a `slack-writer-end` script that copies the draft to the clipboard.

## What to build

A script at `scripts/bin/ai/slack-writer/slack-writer-end` that:

1. Takes draft text as an argument, OR piped via stdin
2. Passes it to `clipboard-write`

This is a minimal hook point — future extensions (e.g., posting directly via Slack API) will be added here.

## Behavioral Tests

**Argument input:**
- passes argument text to clipboard-write

**Stdin input:**
- passes stdin text to clipboard-write

Mock `clipboard-write` via `bats_mock` to verify it receives the correct text.

## Acceptance criteria

- [ ] `slack-writer-end "some text"` calls clipboard-write with "some text"
- [ ] `echo "some text" | slack-writer-end` calls clipboard-write with "some text"
- [ ] All bats tests pass
