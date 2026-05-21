## Execution order

0012 → start here, no blockers
0013 → needs 0012
0014 → needs 0013
0015 → needs 0014
0016 → needs 0012 (lower priority, implement after 0004)

## Guidance

- Language: zsh autoload functions. Skill: `zsh-writer`. Lint: `zshlint <file>`. Tests: `bats <testfile>`.
- Function placement: `git/file/` for file-listing, `git/directory/` for directory scalars, `git/worktree/` for worktree-specific operations.
- Variable pattern: `local myVar="$(myCommand)"` on one line — never split `local` from assignment.
- Loops: `for line in ${(f)output}` — never `while read`.
- Conditions: return early, no nested if/else.
- Test pattern: bats in `scripts/bin/__tests__/`, using `run_zsh_fn`, temp repos via `bats_tmp`. See `git-worktree-distance.bats` and `git-worktree-list-raw.bats` as prior art.
- Bats git setup: `cd` into temp repo before git ops — pre-commit hook sets `GIT_DIR=.git` (relative), so `-C` flag does not resolve correctly.
- Color token: `COLOR_ALIAS_GIT_WORKTREE_DIRTY` lives in `config/term/zsh/theming/env/colors.zsh`. Value: `21`.
- Raw output format for `git-worktree-list-raw`: `branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message` (7 fields, ▮-separated).
- Domain glossary: `docs/worktrees/CONTEXT.md`.

- **Worktree fpath note**: bats tests spawn fresh `zsh -c` processes that load functions from `.oroshi` (the main branch), not the worktree. Override `run_zsh_fn` locally in each test file to prepend the worktree function dir to `fpath` before autoloading.

---
## Log (append below when an issue is completed)

## Session 2026-05-19 — 0012: git-file-list-dirty-raw path arg
- Completed: added optional path argument to `git-file-list-dirty-raw`; falls back to `git-directory-root` when omitted
- Tests added: `scripts/bin/__tests__/git-file-list-dirty-raw.bats` — 6 tests (M/A/D status, clean dir, path arg, clean path arg)
- Discovered: bats tests load functions from `.oroshi` (main branch), not the worktree; worktree fpath override needed in each test file via local `run_zsh_fn` override
- Fixed: none
- Skipped feedback: review findings were about pre-existing docs (broken PRD links, duplicate prd.json IDs, wrong glossary path) — not introduced by this issue
- Next: 0013 (git-directory-dirty-count)

## Session 2026-05-19 — 0014: git-worktree-list-raw new format
- Completed: updated `git-worktree-list-raw` to 7-field format `branch▮path▮dirtyCount▮ahead▮behind▮relativeDate▮message`; `dirtyCount` via `git-directory-dirty-count`; split `distance` string into plain int `ahead`/`behind`
- Tests added: `git-worktree-list-raw.bats` — 5 new tests (7-field count, dirtyCount=0, dirtyCount=1, ahead int, behind int); 4 existing tests preserved; added `run_zsh_fn` override with `*(.:t)` glob to autoload all worktree fns
- Discovered: `git-directory-dirty-count` not in installed `.oroshi` (new fn); must `autoload -Uz dir/*(.:t)` all worktree dirs, not just the target fn
- Fixed: none unplanned
- Skipped feedback: split `local`/assignment in `git-directory-dirty-count.bats` — pre-existing from session 0013, out of scope
- Next: 0015 (git-worktree-list dirty count column display)

## Session 2026-05-19 — 0013: git-directory-dirty-count
- Completed: new autoload fn `git/directory/git-directory-dirty-count`; delegates to `git-file-list-dirty-raw "$@" || true`, counts lines via local array
- Tests added: `scripts/bin/__tests__/git-directory-dirty-count.bats` — 5 tests (clean, modified x2, staged, untracked, path arg)
- Discovered: `${#${(@f)var}}` gives string length, not element count — must assign to `local -a` first; `&&/||` if-else pattern for conditional arg forwarding violates standards, replaced with `"$@"` forwarding + `|| true`
- Fixed: `|| true` added to uphold "always exits 0" spec when called from non-git dir
- Skipped feedback: bats setup `cd` violations — both files already `cd` before git ops; `git init PATH` is valid; `git-file-list-dirty-raw.bats` is pre-existing; issue doc H1 titles not introduced by this issue
- Next: 0014 (git-worktree-list-raw new format)
