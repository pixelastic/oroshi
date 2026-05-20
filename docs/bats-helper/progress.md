## Execution order

issue-001 → start here, no blockers
issue-002 → needs issue-001
issue-003 → needs issue-002
issue-004 → needs issue-003
issue-005 → needs issue-004

## Guidance

- The helper lives at `config/term/bats/helper` — one file, no extension
- It is loaded via `bats_load_library 'helper'` (BATS_LIB_PATH points to `config/term/bats/`)
- Run tests with the `bats` wrapper at `scripts/bin/term/bats/bats` (not the raw binary) — it sets BATS_LIB_PATH correctly
- Use `zshlint` to lint any zsh changes; use `bats <file>` to run tests
- The `bats_` prefix is reserved for our helper functions — bats core also uses it, but our specific names (bats_git_dir, bats_run_function, etc.) are unlikely to collide
- `BATS_*` variables are test-only; `OROSHI_*` variables are runtime — helpers that bridge them (e.g. bats_git_worktree setting OROSHI_WORKTREES_DIR) do so explicitly
- Migration follows tiers strictly: do not start issue-003 until all issue-002 tests pass
- When migrating a test: grep for old names (`run_zsh_fn`, `run_zsh_script`, `mock `, `bats_tmp`, `TMP_DIRECTORY`) to find what needs updating

---
## Log (append below when an issue is completed)

## Session 2026-05-20 — issue-001: Rewrite bats helper
- Completed: Rewrote `config/term/bats/helper` with new `bats_` / `BATS_` API; 8 functions, clean break from old names. Updated `slugify.bats` to use `bats_run_function`.
- Tests added: `config/term/bats/__tests__/helper.bats` — 24 tests covering all 8 functions
- Discovered: `slugify.bats` (Tier 0) used `run_zsh_fn` which needed updating as part of issue-001 acceptance criteria; teardown guard must use `if`/`fi` not `&&` to avoid exit-1 when BATS_TMP_DIR unset
- Fixed: none
- Skipped feedback: `bats_strip_ansi` regex flagged as broken — false positive; `\x1b` IS in the file (hexdump confirmed), test passes. Optional repo arg for `bats_git_worktree` — not in issue-001 spec (`<branch>` only). Applied: `[[ -z ]]` → `[[ == "" ]]`, trimmed header comment, added `$branch` guard, improved `bats_cleanup` usage, removed out-of-scope `helper.bats`
- Next: issue-002 — migrate Tier 1 tests (better-rm.bats, ralph-end.bats) to new API

## Session 2026-05-20 — issue-002: Migrate Tier 1 tests
- Completed: Migrated `better-rm.bats` and `ralph-end.bats` to new helper API
- Tests added: none (migrated existing tests)
- Discovered: `ralph-end.bats` setup had PATH prepend to `../claude/ralph` — non-existent directory, dead code pre-existing
- Fixed: none
- Skipped feedback: PATH stub in `ralph-end.bats:7` — prepend points to non-existent dir, is already a no-op, tests pass without it; fixing out of scope for this migration issue
- Next: issue-003 — migrate Tier 2 tests (git repo and worktree tests)
