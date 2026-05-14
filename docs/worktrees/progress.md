## Execution order

0001-git-directory-is-worktree   → start here, no blockers
0002-git-worktree-main           → start here, no blockers (parallel with 0001)
0003-git-worktree-list-raw       → needs 0001 + 0002
0008-complete-git-worktrees      → needs 0003
0004-git-worktree-create         → needs 0003
0005-git-worktree-list           → needs 0003
0006-git-worktree-switch         → needs 0002 + 0003
0007-git-worktree-delete         → needs 0001 + 0002 + 0003
0009-config-env-aliases          → needs 0004 + 0005 + 0006 + 0007 + 0008
0010-prompt-git-is-worktree      → needs 0001

## Guidance

All issues follow TDD: write the failing BATS test first (it's already written
in each issue file), run it to confirm it's red, then implement until it passes.
Do not skip the red step.

Tests live in scripts/bin/__tests__/. Each test file is named after the function
it tests (e.g. git-directory-is-worktree.bats).

Use the shared helper — load 'test_helper/zsh' — and call autoload functions via
`run_zsh_fn`. No bin wrapper needed. Use `bats_tmp` for temp dirs.

New zsh functions go in:
  - config/term/zsh/functions/autoload/git/worktree/   ← git-worktree-* functions
  - config/term/zsh/functions/autoload/git/directory/  ← git-directory-is-worktree
  - config/term/zsh/functions/autoload/completion/     ← complete-git-worktrees

Completion compdef wrapper _git-worktrees goes in:
  - config/term/zsh/completion/compdef/

Prompt changes go in:
  - config/term/zsh/prompt/git.zsh
  - config/term/zsh/prompt/index.zsh

Domain glossary: docs/worktrees/CONTEXT.md
Full spec per issue: docs/worktrees/issue-XXXX-*.md
Test status tracker: docs/worktrees/prd.json (only update the "passes" field)

---
## Log (append below when an issue is completed)

2026-05-13 — 0001-git-directory-is-worktree — DONE (4/4 tests pass)
2026-05-13 — 0002-git-worktree-main — DONE (3/3 tests pass)

## Session notes — 2026-05-13

### Completed
- 0001-git-directory-is-worktree (4/4 bats tests pass)
  - config/term/zsh/functions/autoload/git/directory/git-directory-is-worktree
  - scripts/bin/git/directory/git-directory-is-worktree (executable, required for bats)

### Issues discovered and resolved
- bats uses bash — zsh autoload functions invisible to `run`. Initial workaround was
  a parallel bin wrapper (scripts/bin/git/directory/git-directory-is-worktree).
  That wrapper was deleted once the shared helper below was built.
- bats npm package was missing (broken symlink). Fixed via `npm install bats`.

### Infrastructure added (same session, follow-up)
- scripts/bin/__tests__/test_helper/zsh.bash — shared bats helper:
  - `run_zsh_fn <fn> [args]` — runs autoload fn via `zsh -c`; works because
    ~/.zshenv sources `oroshi-reload-functions` for every zsh instance
  - `bats_tmp` — returns /tmp/oroshi/bats/<test-file>/<slug>/ for the current test
- scripts/bin/__tests__/git-directory-is-worktree.bats — updated to use helper;
  TEST_TMP renamed TMP_DIRECTORY; bin wrapper deleted (no longer needed)

### Pattern for all future test files
  load 'test_helper/zsh'
  setup() { export TMP_DIRECTORY="$(bats_tmp)"; ... }
  teardown() { rm -rf "$TMP_DIRECTORY"; }
  @test "..." { run_zsh_fn my-autoload-fn [args]; [ "$status" -eq 0 ]; }

### Up next (unblocked)
- 0003-git-worktree-list-raw (needs 0001 + 0002 — both done, now unblocked)
- After 0003: 0004, 0005, 0006, 0007, 0008 all unblock

## Session notes — 2026-05-13 (continued)

### Completed
- 0002-git-worktree-main (3/3 bats tests pass)
  - config/term/zsh/functions/autoload/git/worktree/git-worktree-main
  - scripts/bin/__tests__/git-worktree-main.bats

### Implementation notes
- `git rev-parse --git-common-dir` returns the shared `.git` dir (absolute from
  linked worktrees, relative "." from main repo)
- Resolved to absolute, then took parent with zsh `${var:h}` modifier
- Extra test added beyond prd.json spec: "returns 1 outside any git repo"

### Up next (unblocked)
- 0003-git-worktree-list-raw (both 0001 + 0002 now done)

---

## Session notes — 2026-05-14

### Completed
- 0003-git-worktree-list-raw (4/4 bats tests pass)
  - config/term/zsh/functions/autoload/git/worktree/git-worktree-list-raw
  - scripts/bin/__tests__/git-worktree-list-raw.bats

### Implementation notes
- Parses `git worktree list --porcelain` output: blank-line-separated blocks
- Skips the first block (Git Repo Main); outputs `<branch> <path>` for linked worktrees
- Uses `"${(@f)var}"` (with `@` flag) to preserve empty strings when splitting on newlines;
  plain `${(f)var}` silently drops empty strings, breaking the blank-line detection
- **Critical bug found and fixed:** `local path=""` in zsh clobbers `$path` (zsh's
  tied array for `$PATH`), clearing PATH and making git unfindable. Renamed to `worktreePath`.
- Post-loop flush needed: `$()` strips trailing newlines so the last worktree block
  has no terminating blank line; added `if [[ "$isFirst" == false && -n "$branch" ]]` after loop
- Git lists linked worktrees alphabetically by path, not creation order; test updated to
  match (`feat_dark-mode` < `fix_bug` alphabetically)

### Issues discovered and fixed
- `${(f)var}` vs `"${(@f)var}"`: must use the `@` flag to preserve empty strings
- `local path=""` is a zsh footgun — `$path` is a special tied array for `$PATH`

### Up next (all unblocked by 0003)
- 0004-git-worktree-create
- 0005-git-worktree-list
- 0006-git-worktree-switch
- 0007-git-worktree-delete
- 0008-complete-git-worktrees
