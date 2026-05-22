## PRD

[Unified PreToolUse-Bash Hook](PRD.md)

## What to build

Wire `preToolUse-Bash` into Claude Code and remove the old two-hook system.

Changes:
- Add a Bash matcher entry in `~/.claude/settings.json` pointing to `preToolUse-Bash` (reads from stdin, not a file arg)
- Remove the RTK hook entry from `~/.claude/settings.json`
- Remove the Bash dispatch block from the `preToolUse` dispatcher
- Delete `~/.claude/hooks/rtk-rewrite.sh`

After this issue, RTK rewrites take effect for all Bash commands and the permission prompt uses the rewritten command when applicable.

## Acceptance criteria

- [ ] `~/.claude/settings.json` has a Bash matcher entry for `preToolUse-Bash`
- [ ] `~/.claude/settings.json` has no RTK hook entry
- [ ] `preToolUse` dispatcher has no Bash-specific dispatch block
- [ ] `rtk-rewrite.sh` is deleted
- [ ] Running `git status` via Claude auto-approves (allowlisted) and Claude receives `rtk git status` output

## Blocked by

- [issue-003-pretooluse-bash-orchestrator.md](issue-003-pretooluse-bash-orchestrator.md) (done)
- [issue-005-fix-rtk-rewrite-api.md](issue-005-fix-rtk-rewrite-api.md)
- [issue-006-fix-sequential-execution.md](issue-006-fix-sequential-execution.md)
