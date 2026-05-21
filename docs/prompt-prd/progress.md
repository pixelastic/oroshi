## Execution order

issue-001 → start here, no blockers
issue-002 → needs issue-001
issue-003 → needs issue-001 + issue-002
issue-004 → needs issue-003
issue-005 → needs issue-002 + issue-004

## Guidance

- Autoload functions go in `config/term/zsh/functions/autoload/` under the appropriate namespace (`git/branch/`, `git/worktree/`)
- Ralph scripts go in `scripts/bin/ai/ralph/` as siblings of `ralph-end` and `ralph-state`
- Bats tests for ralph scripts go in `scripts/bin/ai/ralph/__tests__/`
- Use `setopt local_options err_return` (not `set -e`) in autoload functions; use `set -e` in scripts with shebangs
- Use `local var="$(cmd)"` pattern for local variable assignment — never split declaration from assignment
- The branch-slug separator is `▮` (U+25AE) — matches the project-wide field separator convention
- All functions rendering an icon must define it as `local icon="I"` at the top (placeholder for Nerd Font glyph)
- Use `Edit` (never `Write`) when touching files that already contain Nerd Font / powerline glyphs
- `git-worktree-is-ralph` must use `git-directory-is-worktree` function directly, not `GIT_DIRECTORY_IS_WORKTREE` env var
- `ralph-directory` returns an absolute path; verify with a leading `/` check in tests
- Bats tests that need a worktree: create a temp git repo, run `git worktree add` in setup, tear down in teardown

---
## Log (append below when an issue is completed)

## Session 2026-05-21 — 0001: git-branch-slug
- Completed: Created `git-branch-slug` autoload function; updated `git-worktree-create` to call it
- Tests added: `git/branch/__tests__/git-branch-slug.bats` (4 tests: single slash, multiple slashes, plain name, hyphens/underscores)
- Discovered: none
- Fixed: added `[[ -n "$branchSlug" ]] || return 1` guard in `git-worktree-create`; added empty-arg guard in `git-branch-slug`
- Skipped feedback: file path anomaly in review (false positive — files are at correct locations); comment "deleted" (false positive — comment was preserved)
- Next: issue-002 (git-worktree-is-ralph) — depends on issue-001 which is now done
