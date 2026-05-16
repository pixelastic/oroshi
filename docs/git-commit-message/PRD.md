# PRD — git-commit-message performance

## Problem Statement

`git-commit-message` is slow: each invocation spawns a full Claude Code CLI
process (~520ms startup), writes a session file to disk, calls the API, then
deletes the file — totalling ~5 seconds for a short diff. Writing commits is a
high-frequency operation; the latency is consistently noticeable.

## Solution

Replace the zsh autoload function + bin wrapper pair with a single self-contained
Node.js script. The script calls the Anthropic API directly via `fetch()`,
bypassing the Claude Code CLI entirely. A hardcoded system prompt (derived from
the `commit-writer` skill) replaces the skill dispatch. The skill is then
deleted as it has no remaining callers.

Expected end-to-end time: ~500–600ms (down from ~5000ms).

## User Stories

1. As a developer, I want `git-commit-message` to be significantly faster, so
   that the commit workflow feels responsive.
2. As a developer, I want the generated message to follow Conventional Commits
   format with the same quality as before, so that I don't trade speed for
   correctness.
3. As a developer, I want the subject line never to be wrapped mid-word, so
   that `git log --oneline` is always readable.
4. As a developer, I want the body to be wrapped at 72 characters, so that
   `git log` renders cleanly in standard terminals.
5. As a developer, I want `yarn.lock` to be silently excluded from the diff, so
   that lock file noise never pollutes the commit message.
6. As a developer, I want the completion sound to play without blocking the
   script's return, so that Neovim receives the message immediately.
7. As a developer, I want the Neovim gitcommit buffer to populate with the
   generated message exactly as before, so that my editing workflow is
   unchanged.
8. As a developer, I want the script to exit with a clear error message when
   nothing is staged, so that I know why no message was generated.
9. As a developer, I want the script to exit with a clear error message when
   `ANTHROPIC_API_KEY` is not set, so that auth failures are immediately
   diagnosable.
10. As a developer, I want the `commit-writer` skill to be removed once the
    script is in place, so that there is no stale skill pointing to a workflow
    that no longer exists.

## Implementation Decisions

### Architecture

A single Node.js executable replaces both the zsh autoload function
`git-commit-message` and the bin wrapper `git-commit-message-bin`. The new
script is located at `scripts/bin/git/commit/git-commit-message` with a
`#!/usr/bin/env node` shebang. The Neovim config `gitcommit.lua` is updated to
call `git-commit-message` instead of `git-commit-message-bin`.

### Internal structure

The script is organized as a plain object with async methods:

- `getStagedFiles()` — runs `rtk git status --porcelain`, strips excluded files
  (`yarn.lock`), returns an array of file paths. Returns empty array if nothing
  is staged.
- `getDiff(files)` — runs `rtk git diff --cached -- <files>`, returns the diff
  string. `rtk` reduces noise in the output before it reaches the API.
- `generateMessage(diff)` — calls the Anthropic API via native `fetch()` using
  `claude-sonnet-4-5`, with the commit-writer system prompt hardcoded. Reads
  `ANTHROPIC_API_KEY` from `process.env`. Throws on auth error or network
  failure.
- `formatMessage(raw)` — keeps the first line (subject) intact regardless of
  length; wraps every subsequent non-empty line at 72 characters word-boundary.
  Returns the formatted string.
- `playSound()` — spawns `audio-play-oroshi git-commit-message.mp3` detached,
  does not await. Fire-and-forget.
- `run()` — orchestrates the above; writes the message to stdout; exits 1 with
  a message to stderr on any error.

### Dependencies

`firost` and `golgoth` are available as project dependencies. Named imports
only — no god-object usage. `fetch()` is native (Node 22, no SDK needed).
`@anthropic-ai/sdk` is NOT added as a dependency.

### Model

`claude-sonnet-4-6`. Benchmarking showed no meaningful speed difference vs
Haiku on this workload; Sonnet produces higher-quality output (scope
inference, body impact framing).

### System prompt

The full content of the `commit-writer` skill is hardcoded as the system
prompt string inside `generateMessage`. This includes all quality rules:
single-change focus, impact-not-mechanism body, 2-sentence max, plain text
output contract, and the rationalization table. The skill file is deleted at
the end of this PR.

### Diff source

`git diff --cached` (staged changes only), not `git diff HEAD` (which
includes unstaged changes). This produces a smaller, more relevant diff for
commit message generation.

### ESLint

`eslint.config.js` is extended with an override that sets `n/hashbang: off`
for `scripts/bin/**` files, consistent with the existing pattern in
`aberlaas-lint` which already disables `no-process-exit` for that path.

### Sound

`playSound()` uses `child_process.spawn` with `detached: true` and
`stdio: 'ignore'`, then calls `.unref()` so the Node process can exit
immediately without waiting for the audio process.

### Deletions (end of PR)

- `scripts/bin/git/commit/git-commit-message-bin`
- `config/term/zsh/functions/autoload/git/commit/git-commit-message`
- `~/.claude/skills/commit-writer/` (outside repo — manual deletion step)

## Testing Decisions

Tests cover only external behavior, not implementation details. The test for
`formatMessage` is a JS unit test (the function is exported from the script).
No API calls are made in tests.

**`formatMessage` — what makes a good test:**
- Input is the raw string returned by the API (may have a long subject, a blank
  line, and a multi-word body)
- Assert subject line is never broken across lines regardless of length
- Assert body lines never exceed 72 characters
- Assert blank line between subject and body is preserved
- Assert body with short words is not over-wrapped

Prior art: no existing vitest tests in the repo — this will be the first. The
function is extracted as a named export alongside the default script object.

## Further Notes

As a final cleanup issue in this PR: add `--no-session-persistence` to the
`claude-print` function and remove the `--session-id` + `rm -f` dance. This
saves ~1s for all `claude-print` callers (`translate`, `review`). It is
independent of the main Node script work and can be done last.

## Out of Scope
- Streaming output / progressive display of the commit message
- Configurable model or excluded-files list
- Fallback to `claude-print` when `ANTHROPIC_API_KEY` is absent
- Testing the API call, git operations, or sound playback
- Any changes to `translate` or `review`
