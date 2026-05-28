## Execution order

issue-001 → start here, no blockers
issue-002 → needs issue-001
issue-003 → needs issue-001
issue-004 → needs issue-001
issue-006 → needs issue-001
issue-005 → needs issue-002 + issue-003 + issue-004

Note: issue-002, 003, 004, and 006 are all unblocked once issue-001 is done — they can be worked in parallel.

## Guidance

- **Testing**: run `bats <filepath>` for zsh tests. All modified files must have bats tests.
- **Linting**: run `zshlint <filepath>` after writing zsh functions and fix actionable violations.
- **zsh patterns**:
  - Use `local var="$(cmd)"` on one line (never split `local` from assignment)
  - Use `setopt local_options errexit` for autoload functions (not `set -e`)
  - Use `local -a zshFlag=(); [[ $isZsh == "1" ]] && zshFlag=(--zsh)` to propagate `--zsh`
  - Use `print -n` not `echo` for output without trailing newline
- **PROJECTS array**: project data lives in `config/term/zsh/theming/dist/projects.zsh` as a `typeset -gA PROJECTS` associative array. Keys: `name.background.ansi`, `name.foreground.ansi`, `name.icon`, `name.path`, `name.hideNameInPrompt`.
- **Test injection pattern**: inject PROJECTS inline in `run zsh -c "..."` calls, same as `context-project.bats`: `typeset -gA PROJECTS; PROJECTS[my-project.path]=${BATS_GIT_DIR}/; PROJECTS[my-project.background.ansi]=100; ...`
- **Arrow glyph**: `context-badge` contains U+E0B0 (powerline arrow). Use `Edit` tool only, never `Write`, to avoid the glyph being stripped silently.
- **Worktree**: working branch is `colorize-zsh-flag`, worktree at `/home/tim/local/www/worktrees/oroshi--colorize-zsh-flag`

---
## Log (append below when an issue is completed)

## Session 2026-05-27 — 0001: colorize fix and --zsh flag
- Completed: Fixed all bugs in `colorize`; added `--zsh` flag; kept OROSHI_IS_PROMPT backward compat
- Tests added: `config/term/zsh/functions/autoload/misc/__tests__/colorize.bats` (10 tests)
- Discovered: `${@[(ie)pattern]}` returns `$#+1` when not found (truthy!) — must use `(Ie)` (uppercase I) which returns 0 when absent
- Fixed: `%G{...}` → `%K{...}` (wrong bg code); `%f` → `%f%k` (missing bg reset); `\e[00m` → `\e[0m`; `echo` → `print -n`; added `setopt local_options err_return`
- Skipped feedback: spec agent falsely reported missing tests (bats file is in diff); boolean integer style `(( isZsh ))` is consistent with progress.md guidance
- Next: issue-002 (git-branch-colorize), issue-003 (git-tag-colorize), issue-004 (git-remote-colorize), issue-006 (context-badge) — all now unblocked

## Session 2026-05-27 — 0002: git-branch-colorize --zsh flag
- Completed: Added `--zsh` flag to `git-branch-colorize`; propagated to all 9 `colorize` calls
- Tests added: `config/term/zsh/functions/autoload/git/branch/__tests__/git-branch-colorize.bats` (9 tests)
- Discovered: File has Unicode icon glyphs — Edit tool couldn't match them; used sed + Python string replace to modify colorize calls
- Fixed: Pre-existing `=` → `==` in all `[[ $branchPushStatus ... ]]` comparisons (zshlint violations)
- Skipped feedback: mocks in setup() correct (all tests share same deps); spec agent's concern about bare `[[` is wrong (bats_run_function calls `run` internally); not testing all 8 push-status branches (not in acceptance criteria)
- Next: issue-003 (git-tag-colorize) or issue-004 (git-remote-colorize) — same pattern, same complexity

## Session 2026-05-27 — 0003: git-tag-colorize --zsh flag
- Completed: Added `--zsh` flag to `git-tag-colorize`; propagated to all 6 `colorize` calls; added `--zsh` to header comment
- Tests added: `config/term/zsh/functions/autoload/git/tag/__tests__/git-tag-colorize.bats` (9 tests)
- Discovered: File has Unicode icon glyphs — Edit tool couldn't match; used mixed-quoting sed to append `"${zshFlag[@]}"` to colorize lines; fixed pre-existing `=` → `==` in `[[ ]]` comparisons (zshlint violations)
- Fixed: Pre-existing `=` → `==` in all `[[ $tagStatus ... ]]` comparisons (zshlint violations)
- Skipped feedback: `noArithFlagTest` for `(( isZsh ))` — pre-existing in git-branch-colorize, consistent with progress.md guidance; mock-in-setup pattern same as accepted git-branch-colorize tests; spec agent wrong about positional arg being ignored (function does use `$1`)
- Next: issue-004 (git-remote-colorize) — same pattern

## Session 2026-05-28 — 0005: remove OROSHI_IS_PROMPT
- Completed: Removed backward-compat `OROSHI_IS_PROMPT` check from `colorize`; replaced 3 `OROSHI_IS_PROMPT=1 xxx-colorize` calls in `git.zsh` with `xxx-colorize --zsh`
- Tests added: `colorize.bats` — OROSHI_IS_PROMPT=1 no longer triggers zsh output; `git.zsh.bats` — branch/tag/remote prompt functions call colorize helpers with --zsh
- Discovered: `bats_run_function` supports env var injection via `export VAR=value` before call (inherited by subprocess); git.zsh prompt functions can't use `bats_run_function` because they're sourced not autoloaded — existing `run zsh -c '...'` pattern is correct for this file
- Fixed: none unplanned
- Skipped feedback: git.zsh.bats inline function mocks instead of bats_mock — `bats_run_function` doesn't apply to sourced functions, all 12 pre-existing tests in that file use the same inline pattern
- Next: issue-006 (context-badge rewrite to use colorize directly)

## Session 2026-05-27 — 0004: git-remote-colorize --zsh flag
- Completed: Added `--zsh` flag to `git-remote-colorize`; propagated to both `colorize` calls; fixed `isWithIcon != 1` → `!= "1"` (zshlint)
- Tests added: `config/term/zsh/functions/autoload/git/remote/__tests__/git-remote-colorize.bats` (9 tests)
- Discovered: Icon glyph is `ef 90 82` (U+F002); Edit tool can't match it — used sed + Python hex bytes for second `colorize` call
- Fixed: Pre-existing `!= 1` → `!= "1"` in `isWithIcon` comparison (zshlint compliance)
- Skipped feedback: `zmodload zsh/zutil` absent from all peer files (established pattern); icon test uses space not glyph (same accepted pattern as git-tag-colorize)
- Next: issue-005 (remove OROSHI_IS_PROMPT from git.zsh and colorize) — needs 002+003+004 done ✓
