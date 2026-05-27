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
  - Use `local -a zshFlag=(); (( isZsh )) && zshFlag=(--zsh)` to propagate `--zsh`
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
