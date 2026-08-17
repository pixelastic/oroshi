## TLDR

Rewrite `plan-start` to create the plan directory in `$OROSHI_PLANS_DIR` with `git init`.

## What to build

Modify `tools/term/zsh/config/functions/autoload/ai/plan/plan-start`:

1. After ensuring we're in a worktree (existing logic), resolve the plan dir via `plan-directory`.
2. If the plan dir doesn't exist, create it: `mkdir -p`, `git init`, create an empty initial commit.
3. Output JSON with `planDir` pointing to the external location.

The worktree creation logic stays unchanged — `plan-start` still calls `git-worktree-create` when needed.

## Behavioral Tests

**plan-start.bats:**
- Creates plan dir in `$OROSHI_PLANS_DIR/<slug>/`
- Plan dir is a git repository (`git -C <planDir> rev-parse --git-dir` succeeds)
- Plan dir has an initial commit
- JSON output `planDir` points to `$OROSHI_PLANS_DIR/<slug>/`
- Idempotent: calling twice doesn't re-init or error

## Acceptance criteria

- [ ] Plan dir created in `$OROSHI_PLANS_DIR/`, not in worktree
- [ ] Plan dir is a git repo with initial commit
- [ ] JSON `planDir` field points to external location
- [ ] Idempotent on repeated calls
