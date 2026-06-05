## TLDR

Lint pass on tools/ai tests — Claude hooks, statusline, rtk (6 files).

## What to build

Run `bats-lint` on: `preToolUse-Bash.bats`, `preToolUse-Bash-rtk.bats`, `preToolUse-Bash-solkan.bats`, `stop.bats`, `statusline.bats`, `rtk.bats`. Fix violations or encode rules.

## Behavioral Tests

**bats-lint violations resolved:**
- `bats-lint` exits 0 on each file

**Tests still pass:**
- `bats` exits 0 on each file

## Acceptance criteria

- [ ] `bats-lint` exits 0 on all 6 files
- [ ] `bats` passes on all 6 files
- [ ] Developer review sign-off
