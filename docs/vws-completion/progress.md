## Execution order

issue-001 → start here, no blockers
issue-007 → start here, no blockers (independent of all others)
issue-002 → needs issue-001
issue-003 → needs issue-001
issue-004 → needs issue-001
issue-005 → needs issue-002 + issue-003 + issue-004
issue-006 → needs issue-002

## Guidance

- All autoload functions live in `config/term/zsh/functions/autoload/` under the appropriate subdirectory (`git/worktree/`, `completion/`, etc.)
- Bats tests live in a `__tests__/` subdirectory next to the function file
- Use `▮` (U+25AE) as the field separator throughout — never a plain pipe or comma
- Use `setopt local_options err_return` (not `set -e`) for autoload functions
- Use `local var="$(cmd)"` pattern for variable assignment — never split `local` from assignment, never group multiple locals on one line
- The `bats_git_dir` / `bats_git_worktree` helpers set up temp repos; always `cd` into the repo before running functions (pre-commit hook sets `GIT_DIR=.git` relative)
- `styling.zsh` is in `config/term/zsh/completion/styling.zsh` — add `zstyle` entries in the Git section following the existing branch pattern
- Prior art for distance tests: `git-worktree-distance.bats` (same setup, `git commit --allow-empty`)
- Prior art for completion tests: `complete-git-worktrees.bats` (existing file to update)

---
## Log (append below when an issue is completed)

## Session 2026-05-21 — issue-001: create git-worktree-distance-raw
- Completed: Created `git-worktree-distance-raw` autoload function and 5 bats tests
- Tests added: `outputs 0▮0 for branch with no divergence`, `ahead count`, `behind count`, `exits 1 outside git repo`, `exits 1 for unknown branch`
- Discovered: progress.md guidance incorrectly said `errexit`; memory confirms `err_return` for autoload — fixed the guidance note
- Fixed: `errexit` → `err_return`; simplified test assertions to direct string comparison; added missing unknown-branch test (from review)
- Skipped feedback: "IFS-dependent read split" (minor fragility note, not actionable); "possible silent failure via :-0 fallback" (rev-list --count always emits two fields or nothing, so fallback is unreachable)
- Next: issue-003 (refactor is-ahead/is-behind) or issue-004 (refactor prompt-git.zsh)

## Session 2026-05-21 — issue-002: refactor git-worktree-list-raw
- Completed: Replaced inline `git rev-list` block with `git-worktree-distance-raw "$entryBranch"` call; split `▮` result into ahead/behind with `|| true` fallback inside subshell
- Tests added: `delegates ahead/behind to git-worktree-distance-raw` (stub-based RED test that failed before refactoring, passes after)
- Discovered: Pre-existing linter violations at lines 7 and 11 (localOrReturn, noGroupedLocals) required fixing per ralph rules
- Fixed: Replaced `|| return 1` after `local porcelain` with manual empty-string guard; split grouped `local worktreePath="" branch="" isFirst=true` into 3 separate locals
- Skipped feedback: "Mock stub broken" — incorrect; bats_run_function sources $BATS_TMP_DIR/mock.zsh before the call, stub IS working (test failed with old code, passes with new code). "|| true redundant" — not redundant; without it, err_return aborts the loop when git-worktree-distance-raw fails. "Scope creep on local fixes" — required by ralph linter rule.
- Next: issue-003 (refactor is-ahead/is-behind) or issue-004 (refactor prompt-git.zsh)

## Session 2026-05-21 — issue-006: improve complete-git-worktrees
- Completed: Rewrote `complete-git-worktrees` to output `name:description` format with dirty/ahead/behind counts (zero-suppressed) and last commit message
- Tests added: `output is in name:description format`, `includes dirty count in description when non-zero`, `suppresses zero counts in description`, `outputs main with no description when outside a git repo`
- Discovered: Existing test "outputs only 'main' when no linked worktrees exist" expected plain `main`; updated to `main:*` format. Review flagged `local mainDesc` split — fixed via subshell inline. Review flagged `git rev-parse --show-toplevel` — replaced with `git-worktree-main`. Review flagged `git log -1` without branch arg — fixed to `git log -1 --format="%s" main`.
- Fixed: `local mainDesc` / `local desc` split-declarations inlined via subshell `$([[ ... ]] && echo ... || echo ...)`; `git-worktree-main` used instead of `git rev-parse`; `git log -1 main` targets correct branch
- Skipped feedback: "variable bug $message vs $mainMessage" — false positive, code already uses `mainMessage` in main block, all tests pass; "US7/US10-13 missing" — separate issues (007, 003, 004, 005)
- Next: issue-007 (worktree switch coloring, no blockers) or issue-003 (refactor is-ahead/is-behind)
