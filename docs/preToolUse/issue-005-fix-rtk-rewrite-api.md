## PRD

[Unified PreToolUse-Bash Hook](PRD.md)

## What to build

Fix `preToolUse-Bash-rtk` to use `rtk rewrite` instead of parsing `rtk --help`.

The current implementation detects RTK-rewritable commands by parsing the Commands section of `rtk --help`. This is fragile — it depends on help text format and will break silently if RTK changes its output format.

`rtk rewrite` is the canonical API for hooks (documented as "single source of truth for hooks"):
- exit 0 + stdout = rewritten command
- exit 1 + no output = RTK has no equivalent (ignore)

## Acceptance criteria

- [ ] `preToolUse-Bash-rtk` uses `rtk rewrite <cmd>` to determine if a command can be rewritten
- [ ] prints the rewritten command (stdout of `rtk rewrite`) when RTK rewrites
- [ ] prints the original command unchanged when RTK ignores (exit 1)
- [ ] is idempotent when command already uses RTK prefix

## Blocked by

- [issue-002-pretooluse-bash-rtk.md](issue-002-pretooluse-bash-rtk.md) (done)
