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
