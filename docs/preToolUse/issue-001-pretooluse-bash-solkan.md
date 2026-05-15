## PRD

[Unified PreToolUse-Bash Hook](PRD.md)

## What to build

Create `preToolUse-Bash-solkan` — a subscript that decides whether Claude's bash command should be auto-approved or escalated to the user.

It receives the raw command as `$1`, checks it against the solkan allowlist, and exits 0 (allow) or 1 (ask). For compound commands (`&&`, `||`, `;`, pipes), all subcommands must be allowlisted for exit 0.

Script lives at `config/ai/claude/claudecode/hooks/preToolUse-Bash-solkan`.

Tests live at `scripts/bin/__tests__/preToolUse-Bash-solkan.bats`. Write tests first (red), then implement.

## Acceptance criteria

- [ ] exits 0 for an allowlisted simple command (`git status`)
- [ ] exits 1 for a non-allowlisted simple command (`wget evil.com`)
- [ ] exits 0 for a compound command where all subcommands are allowlisted (`git status && git log --oneline`)
- [ ] exits 1 for a compound command with one non-allowlisted subcommand (`git status && wget evil.com`)

## Blocked by

None — can start immediately.
