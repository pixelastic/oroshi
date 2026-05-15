## Execution order (v2 — current cycle)

0001-git-github-project-name     → done (existing function, no new code)
0002-git-worktree-create-naming  → done (needs 0001)
0003-alias-rename-vwsm           → no blockers
0004-complete-git-worktrees-linked → no blockers
0005-git-worktree-distance       → no blockers
0006-git-worktree-list-enriched  → needs 0005
0007-git-directory-is-worktree-cache → no blockers
0008-git-worktree-project        → no blockers
0009-prompt-path-worktree        → needs 0007 + 0008
0010-prompt-git-worktree-branch  → needs 0005 + 0007

## Guidance

All issues follow TDD: write the failing BATS test first (it's already written
in each issue file), run it to confirm it's red, then implement until it passes.
Do not skip the red step.

`bats` and `zshlint` are in your $PATH

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
2026-05-14 — 0003-git-worktree-list-raw — DONE (4/4 tests pass)
2026-05-14 — 0004-git-worktree-create — DONE (5/5 tests pass)
2026-05-14 — 0006-git-worktree-switch — DONE (4/4 tests pass)
2026-05-14 — 0007-git-worktree-delete — DONE (4/4 tests pass)
2026-05-14 — 0005-git-worktree-list — DONE (3/3 tests pass)
2026-05-14 — 0008-complete-git-worktrees — DONE (5/5 tests pass)

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
- 0004-git-worktree-create ✓
- 0005-git-worktree-list
- 0006-git-worktree-switch
- 0007-git-worktree-delete
- 0008-complete-git-worktrees

---

## Session notes — 2026-05-14 (continued)

### Completed
- 0004-git-worktree-create (5/5 bats tests pass)
  - config/term/zsh/functions/autoload/git/worktree/git-worktree-create
  - scripts/bin/__tests__/git-worktree-create.bats

### Implementation notes
- Uses `git-branch-exists` helper (not raw `git show-ref`) to check branch existence
- Uses `git-worktree-main` to derive repo name via `:t` modifier
- Branch slug derived with `${branch//\//_}` (zsh substitution, no subprocess)
- Idempotency: `[[ -d "$worktreeDir" ]]` guard before `git worktree add`
- `cd` at end is safe — `setopt local_options errexit` covers failure

### Zshlint fix
- Added SC2164 to excluded rules in `scripts/bin/zsh/zshlint`
- SC2164 ("use cd || exit") is a false positive when `setopt errexit` is active

### Up next
- 0005-git-worktree-list
- 0008-complete-git-worktrees

---

## Session notes — 2026-05-14 (continued)

### Completed
- 0006-git-worktree-switch (4/4 bats tests pass)
  - config/term/zsh/functions/autoload/git/worktree/git-worktree-switch
  - scripts/bin/__tests__/git-worktree-switch.bats

### Implementation notes
- Parses `git-worktree-list-raw` output (`<branch> <path>`) with `${line%% *}` / `${line#* }`
- Guards: `[[ -n "$line" ]] || continue` and `[[ "${line%% *}" == "$branch" ]] || continue` safe with `errexit`
- `main` shortcut calls `git-worktree-main` directly without touching list-raw
- cd tests use `run zsh -c '... && echo "$PWD"'` pattern (same as git-worktree-create)

### Up next
- 0005-git-worktree-list ✓
- 0008-complete-git-worktrees ✓
- 0009-config-env-aliases (now unblocked)

---

## Session notes — 2026-05-14 (continued)

### Completed
- 0005-git-worktree-list (3/3 bats tests pass)
  - config/term/zsh/functions/autoload/git/worktree/git-worktree-list
  - scripts/bin/__tests__/git-worktree-list.bats

### Implementation notes
- Wraps `git-worktree-list-raw`, extracts branch name with `${rawLine%% *}`
- Passes branch name to `git-branch-colorize` for coloring
- Returns 0 with empty output when no worktrees exist (early return on empty rawOutput)
- Extra test: "returns empty output when no worktrees exist" (3rd test, beyond prd.json spec)
- Post-commit fix: `[[ -n "$branch" ]] || continue` → `[[ "$branch" == "" ]] && continue` (style: explicit empty check + &&, not -n/||)
- Post-commit fix: added `[ "$status" -eq 0 ]` to "returns empty output" test

### Bug discovered and fixed: pre-commit hook GIT_DIR breaks git worktree add in bats tests
Root cause: hook sets `GIT_DIR=.git` (relative). `git worktree add` internally chdirs into the
new worktree dir, where `.git` is a FILE — so `GIT_DIR=.git` resolves to that file and any
path under it (e.g. `.git/index`) fails with "Not a directory".

Fix (two parts):
1. `git_env_clean` helper added to test_helper/zsh.bash — unsets GIT_DIR, GIT_INDEX_FILE,
   GIT_OBJECT_DIRECTORY, GIT_WORK_TREE
2. `run_zsh_fn` updated to unset those vars before invoking the function (covers functions
   that call git worktree add internally, like git-worktree-create)

`git_env_clean` called at start of setup() in all 7 affected bats files.
All 31 tests pass with `GIT_DIR=.git GIT_INDEX_FILE=.git/index` to simulate hook environment.

### Up next
- 0008-complete-git-worktrees (only remaining blocker for 0009)

---

## Session notes — 2026-05-14 (continued)

### Completed
- 0007-git-worktree-delete (4/4 bats tests pass)
  - config/term/zsh/functions/autoload/git/worktree/git-worktree-delete
  - scripts/bin/__tests__/git-worktree-delete.bats

### Implementation notes
- Parses `git-worktree-list-raw` output to find worktree path for the given branch
- Guards inside-worktree cd: `[[ "$PWD" == "$worktreePath"* ]]` before `git-worktree-main`
- Uses `git worktree remove --force` (not `rm -rf`) so git cleans up its own metadata
- Does NOT delete the branch (per ADR 0002)
- Extra test added beyond prd.json spec: "returns 1 if worktree does not exist" (4th test)

### Up next
- 0008-complete-git-worktrees ✓
- 0009-config-env-aliases (now unblocked)

---

## Session notes — 2026-05-14 (continued)

### Completed
- 0008-complete-git-worktrees (5/5 bats tests pass)
  - config/term/zsh/functions/autoload/completion/complete-git-worktrees
  - config/term/zsh/completion/compdef/_git-worktrees
  - config/term/zsh/completion/compdef.zsh — wired _git-worktrees to git-worktree-switch + git-worktree-delete
  - scripts/bin/__tests__/complete-git-worktrees.bats

### Implementation notes
- Wraps `git-worktree-list-raw`; always prepends `main` before iterating branches
- `return 0` on `git-worktree-list-raw` failure (outside git repo) → outputs just `main` (safe default for completion)
- 2 extra tests beyond prd.json spec: "no worktrees → only main" and "outside git repo → only main"
- `_git-worktrees` compdef uses `-V` + `completion-header` with `$COLOR_ALIAS_GIT_BRANCH` (no worktree-specific color constant)

### Up next
- 0010-prompt-git-is-worktree (only needs 0001, which is done)

---

## Session 2026-05-14 — 0009: config: env var, aliases, compdef

- Completed: `OROSHI_WORKTREES_DIR` exported in zshenv.zsh; `vwtc/vwtl/vwts/vwtR` aliases in aliases/git/worktree.zsh; `git-worktree-create` added to `_git-branches-local` block in compdef.zsh
- Tests added: scripts/bin/__tests__/git-worktree-config.bats (5 tests)
- Discovered: `OROSHI_WORKTREES_DIR` must use `${:-$HOME/...}` guard (not bare `export`) so tests can override it; `$HOME` required inside `${}` — `~/` doesn't expand there
- Fixed: none (GIT_WORKTREE color and `_git-worktrees` compdef were already present from earlier sessions)
- Skipped feedback: reviewer suggested `~/` over `$HOME` — not applicable inside `${:-}` expansion; `zsh -i` fragility — per issue spec; remote branch completion — out of scope
- Next: 0010-prompt-git-is-worktree

---

## Session 2026-05-15 — 0010: prompt: git_is_worktree
- Completed: `oroshi-prompt-populate:git_is_worktree` added to git.zsh; `git_is_worktree` added to `OROSHI_SYNCHRONOUS_PROMPT_PARTS` and `oroshi-prompt-left` in index.zsh
- Tests added: scripts/bin/__tests__/oroshi-prompt-git-is-worktree.bats (2 tests)
- Discovered: none
- Fixed: none
- Skipped feedback: none
- Next: all prd.json issues complete

---

## Session 2026-05-15 — 0001: git-github-project-name (was: git-github-remote-name)
- Completed: no new code — `git-github-project-name` already existed (renamed from `git-github-remote-project-name` via commit `73a53ae6`). SSH + HTTPS URL parsing covered by existing function + tests in `git-github-project-name.bats`. Fallback (no remote, dot-stripping) deferred to issue 0002 inline.
- Tests added: none (existing `git-github-project-name.bats` covers SSH + HTTPS cases)
- Discovered: previous session recorded this as a new function `git-github-remote-name` — incorrect; the function was already present under the renamed naming convention
- Fixed: none
- Skipped feedback: `git_env_clean` in setup() — already handled by `unset` at load time in helper.bash
- Next: 0002-git-worktree-create-naming (now unblocked by 0001)

---

## Session 2026-05-15 — 0002: git-worktree-create — fix repo name
- Completed: `git-worktree-create` calls `git-github-project-name` for repo name; falls back to `${${repoMain:t}##.#}` (extendedglob, strips leading dots in one expression); guard replaced with `git-directory-is-repository || return 1`; `-n` condition replaced with `== ""`
- Tests added: test 7 "strips leading dot from repo name in dot-prefixed repo folder"; test 8 "returns 1 outside any git repo"
- Discovered: previous session incorrectly named the function `git-github-remote-name`; actual function is `git-github-project-name` (renamed via commit `73a53ae6`). No new function needed.
- Fixed: user refactored file using `git-branch-create` which exits 1 when branch exists — reverted to `git-branch-exists "$branch" || git branch "$branch"`
- Skipped feedback: reviewer flagged function name mismatch — intentional per user; other flags were about prior session's files
- Next: 0003-alias-rename-vwsm (no blockers)

---

## Session 2026-05-15 — 0003: alias rename vwc/vwl/vws/vwR + vwsm
- Completed: renamed `vwtc/vwtl/vwts/vwtR` → `vwc/vwl/vws/vwR`; added `vwsm='vws main'` in `config/term/zsh/aliases/git/worktree.zsh`
- Tests added: none (user confirmed no tests needed for aliases)
- Discovered: none
- Fixed: none
- Fixed (post-review): `local repoMain=""` moved to top level; `return 0` on existing worktree now cds first
- Skipped feedback: raw `git worktree add` (no helper exists); raw `git branch` (intentional); if-block style flag (if body with errexit semantics is safer than && chain here); scope-creep items (already committed from 0002); `##.#` vs `##.*` reviewer suggestion (incorrect — `##.*` would strip entire string)
- Next: 0004-complete-git-worktrees-linked (no blockers)
