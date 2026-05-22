## PRD

[Unified PreToolUse-Bash Hook](PRD.md)

## What to build

Fix `preToolUse-Bash` to run Solkan and RTK sequentially instead of in parallel.

The current implementation runs Solkan in a background job while RTK runs in the foreground, then `wait`s for Solkan. The intended execution order (per glossary) is: **Solkan first, RTK second** — always sequential.

Parallel execution adds complexity for no meaningful gain: both scripts are fast, and the sequential model matches the conceptual model (Solkan decides allow/reject, then RTK decides rewrite/ignore).

## Acceptance criteria

- [ ] Solkan runs to completion before RTK is called
- [ ] No background jobs (`&`) in the script
- [ ] All 4 cases still produce correct output (existing tests pass)

## Blocked by

- [issue-003-pretooluse-bash-orchestrator.md](issue-003-pretooluse-bash-orchestrator.md) (done)
