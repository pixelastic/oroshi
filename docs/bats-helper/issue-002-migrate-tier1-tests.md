## PRD

[PRD.md](./PRD.md) — Bats Helper Redesign

## What to build

Migrate the two Tier 1 test files to the new helper. These tests need a sandbox but no git
repo and no mocks:

- `scripts/bin/misc/__tests__/better-rm.bats`
- `scripts/bin/ai/ralph/__tests__/ralph-end.bats`

Replace `bats_tmp` with `bats_tmp_dir`, `TMP_DIRECTORY` with `BATS_TMP_DIR`, `run_zsh_script`
with `bats_run_script`, and add a `teardown()` calling `bats_cleanup`.

## Acceptance criteria

- [ ] `better-rm.bats` uses `bats_tmp_dir` in setup and `bats_cleanup` in teardown
- [ ] `ralph-end.bats` uses `bats_tmp_dir` in setup and `bats_cleanup` in teardown
- [ ] Neither file references old names (`bats_tmp`, `TMP_DIRECTORY`, `run_zsh_script`)
- [ ] All tests in both files pass

## Blocked by

- issue-001 — new helper must exist before migration
