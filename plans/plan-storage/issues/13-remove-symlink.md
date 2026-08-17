## TLDR

Remove the bootstrap symlink and validate that everything resolves via `$OROSHI_PLANS_DIR` only.

## What to build

1. Remove the `plans/plan-storage` symlink from this worktree.
2. Remove the `plans/` directory from the repo if empty.
3. Run the full test suite to verify nothing depends on local plan paths.
4. Manually verify: prompt shows plan progress, `vfe` opens plan artifacts, `ralph-is-running` detects correctly, statusbar displays correctly.

## Behavioral Tests

**Skip** — validation issue, not new behavior.

## Acceptance criteria

- [ ] `plans/` symlink removed from repo
- [ ] `plans/` directory removed from repo (if empty)
- [ ] All bats tests pass
- [ ] ZSH prompt still shows plan progress
- [ ] Claude statusbar still shows plan progress
- [ ] `vfe` still opens dirty plan artifacts
- [ ] `ralph-is-running` still detects active sessions
