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
