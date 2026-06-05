## TLDR

Final global pass — run bats-lint on all 120 files with the fully-evolved ruleset.

## What to build

After all 16 domain issues are done, the bats-lint ruleset will have grown. Rules added in later domains may fire on files cleaned in earlier domains. Run `bats-lint` on every `.bats` file in the repo, fix any remaining violations, and confirm all tests still pass.

This is the only issue that can be run autonomously (AFK) — no new rules expected at this stage.

## Behavioral Tests

**Clean sweep:**
- `bats-lint` exits 0 on every `.bats` file in the repo

**No regressions:**
- `bats` passes on every `.bats` file in the repo

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all ~120 files
- [ ] `bats` passes on all ~120 files
- [ ] No new rules introduced (fixes only)
- [ ] Developer review sign-off
