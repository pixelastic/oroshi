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

## Session 2026-05-20 — issue-003: Migrate Tier 2 tests
- Completed: Migrated all 21 Tier 2 test files to new helper API; fixed two bugs in `bats_git_worktree`
- Tests added: none (migrated existing tests)
- Discovered: `bats_git_worktree` had two bugs: (1) `mkdir -p "$worktrees_dir"` didn't create parent dirs for slash-branches like `fix/bug`; fixed to `mkdir -p "${wt_path:h}"`. (2) `--new-branch=<branch>` flag doesn't exist in git 2.43 — only `-b` works; fixed accordingly
- Fixed: `config/term/bats/helper` — `bats_git_worktree` slash-branch support + git flag
- Skipped feedback: `git-worktree-push.bats` missing guard after `local fixHead="$(git rev-parse HEAD)"` — `variables.md` guard rule is for zsh functions, not bats (bash) tests; test assertion catches failure anyway. `git-worktree-pull.bats` manual `git init` boilerplate in "no-main" test — unavoidable, `bats_git_dir` always creates `main` branch. Scope creep noted (`allowlist.json` path fix, helper bug fixes) — helper fixes were required to make migration work at all.
- Next: issue-004 — migrate Tier 3 tests (ralph.bats, review.bats, git-worktree-create.bats)

## Session 2026-05-20 — issue-004: Migrate Tier 3 tests
- Completed: Migrated `review.bats` and `git-worktree-create.bats` to new helper API; confirmed `ralph.bats` already used new API (all 8 tests passing, no changes needed)
- Tests added: none (migrated existing tests)
- Discovered: `$0` inside a sourced script = sourced file path (not `-c` arg0), so `${0:A:h}` in `review` script resolves correctly without changes to `bats_run_script`; `bats_git_dir '.dot-repo'` can create a second repo in the same sandbox without clobbering the helper's git config setup
- Fixed: `.dot-repo` test replaced manual git init boilerplate with `bats_git_dir '.dot-repo'`
- Skipped feedback: `REVIEW_SCRIPT` at file scope (ralph.bats uses same pattern; it's established practice); `ralph.bats` review flagged as "not migrated" — false positive, file already used new API
- Next: issue-005 — migrate Tier 4 tests (prompt/git.zsh.bats, prompt/path.zsh.bats)

## Session 2026-05-20 — issue-005: Migrate Tier 4 tests
- Completed: Migrated `prompt/git.zsh.bats` and `prompt/path.zsh.bats` to new helper API; all 11 tests pass
- Tests added: none (migrated existing tests)
- Discovered: `path.zsh.bats` uses double-quoted `run zsh -c "..."` strings — `$BATS_GIT_DIR` expands correctly in bash scope before being passed to zsh, same as old `$TMP_DIRECTORY` pattern; `bats_git` works for main-repo commits in worktree-distance tests
- Fixed: none
- Skipped feedback: indentation inconsistency (`path.zsh.bats` uses 2-space vs tabs in `git.zsh.bats`) — pre-existing, out of scope; `config/ai/claude/skills/review/SKILL.md` path fix in diff — pre-existing working-tree change, valid but not part of this issue
- Next: all issues complete — bats helper migration done
