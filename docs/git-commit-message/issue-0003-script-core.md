## PRD

docs/git-commit-message/PRD.md

## What to build

Implement the core happy path of the `git-commit-message` Node.js script
end-to-end: get staged files, build the diff, call the Anthropic API, format
the output, and print it to stdout.

Key decisions:
- `rtk git status --porcelain` to list staged files, filtering out `yarn.lock`
- `rtk git diff --cached -- <files>` for the diff (staged changes only, not `git diff HEAD`)
- Direct Anthropic API call via native `fetch()` — no SDK, no Claude CLI
- Model: `claude-sonnet-4-5`
- System prompt: full `commit-writer` skill content hardcoded in `generateMessage`
- `ANTHROPIC_API_KEY` read from `process.env`
- Output: `formatMessage(raw)` result written to stdout
- Imports: named imports from `firost`/`golgoth` only; no god-object usage

The script lives at `scripts/bin/git/commit/git-commit-message` with a
`#!/usr/bin/env node` shebang. The `package.json` `type` is already `"module"`,
so use ESM imports.

## Acceptance criteria

- [ ] Script produces a valid Conventional Commits message on stdout when files are staged
- [ ] Diff uses `git diff --cached` (staged only)
- [ ] `yarn.lock` is excluded even when staged
- [ ] `yarn lint` passes on the new script
- [ ] No Claude CLI process is spawned

## Blocked by

- issue-0002-format-message.md
