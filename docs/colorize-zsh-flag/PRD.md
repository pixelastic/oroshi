# PRD — colorize: `--zsh` flag and removal of `OROSHI_IS_PROMPT`

## Problem

`colorize` is the central colorization helper for the zsh prompt. It has several bugs and a poor API:

1. **Silent bugs**: `%G{bg}` instead of `%K{bg}` (wrong zsh background code), missing `\e` before ANSI sequences (ANSI mode non-functional), suffix `%f` instead of `%f%k` (background not reset in zsh mode).
2. **Implicit API**: zsh mode is activated via `OROSHI_IS_PROMPT=1` env var, forcing callers to set an environment variable rather than pass a flag — implicit coupling, hard to trace.
3. **`echo` instead of `print -n`**: each direct call to `colorize` appends a newline, preventing concatenation of multiple calls (e.g. in `context-badge`).
4. **`project-colorize`**: dead code that duplicated `context-badge` logic — already deleted.

## Solution

Fix `colorize`, add an explicit `--zsh` flag, and propagate it through the entire call chain up to `git.zsh`. Remove `OROSHI_IS_PROMPT` once propagation is complete. Rewrite `context-badge` to call `colorize` directly instead of using internal `_badge`/`_trailing_arrow` helpers.

## User Stories

- As a developer, when I call `colorize text fg bg --zsh`, I get zsh-prompt-formatted colored text (`%F{}`/`%K{}`/`%f%k`) without setting an environment variable.
- As a developer, when I call `colorize text fg bg` (no `--zsh`), I get correctly formed ANSI sequences (with `\e`).
- As a developer, I can call `colorize` multiple times in a row and outputs concatenate without stray newlines.
- As the zsh prompt, `context-badge --zsh` produces a complete Context Badge (Project Badge + optional Worktree Badge) using `colorize` for each colored segment.
- As the zsh prompt, `git-branch-colorize --with-icon --zsh` produces a zsh-prompt-formatted colored branch name, without `OROSHI_IS_PROMPT`.

## Implementation Decisions

### colorize

File: `config/term/zsh/functions/autoload/misc/colorize`

- Add `zmodload zsh/zutil` + `zparseopts -E -D --zsh=flagZsh`
- `local isZsh=${#flagZsh}`; keep backward compat: `[[ "$OROSHI_IS_PROMPT" == 1 ]] && isZsh=1` during transition, removed in issue-005
- Replace `echo` with `print -n`
- Fix `%G{bg}` → `%K{bg}`
- Fix ANSI sequences: add `local esc=$'\e'` and prefix `\e` before `[38;5;...m` and `[48;5;...m`
- Change zsh suffix: `%f` → `%f%k`; ANSI suffix: `[00m` → `${esc}[0m`

### git-branch-colorize

File: `config/term/zsh/functions/autoload/git/branch/git-branch-colorize`

- Add `--zsh=flagZsh` to existing `zparseopts`
- Build `local -a zshFlag=(); (( ${#flagZsh} )) && zshFlag=(--zsh)`
- Pass `"${zshFlag[@]}"` to every `colorize` call (~8 call sites)

### git-tag-colorize

File: `config/term/zsh/functions/autoload/git/tag/git-tag-colorize`

- Same pattern as `git-branch-colorize`

### git-remote-colorize

File: `config/term/zsh/functions/autoload/git/remote/git-remote-colorize`

- Same pattern as `git-branch-colorize`

### git.zsh

File: `config/term/zsh/prompt/git.zsh`

- Replace the 3 calls:
  - `$(OROSHI_IS_PROMPT=1 git-branch-colorize --with-icon)` → `$(git-branch-colorize --with-icon --zsh)`
  - `$(OROSHI_IS_PROMPT=1 git-tag-colorize --with-icon)` → `$(git-tag-colorize --with-icon --zsh)`
  - `$(OROSHI_IS_PROMPT=1 git-remote-colorize --with-icon)` → `$(git-remote-colorize --with-icon --zsh)`
- Remove `OROSHI_IS_PROMPT` check from `colorize`

### context-badge

File: `config/term/zsh/functions/autoload/project/context-badge`

- Remove `_badge` and `_trailing_arrow` helpers
- Build `local -a zshFlag=(); (( isZsh )) && zshFlag=(--zsh)`
- Call `colorize` directly for each segment:
  - Project Badge: `colorize " ${projectIcon}${displayName} " "$projectFg" "$projectBg" "${zshFlag[@]}"`
  - Transition arrow (if worktree): `colorize "${arrow}" "$projectBg" "$branchBg" "${zshFlag[@]}"`
  - Worktree Badge: `colorize " ${worktreeName} " "255" "$branchBg" "${zshFlag[@]}"`
  - Trailing arrow: `colorize "${arrow}" "$projectBg"/"$branchBg" "" "${zshFlag[@]}"`
- Read project data from the `PROJECTS` associative array: `.background.ansi`, `.foreground.ansi`, `.icon`, `.hideNameInPrompt`

### Recommended implementation order

1. `colorize` (foundation for everything)
2. `git-branch-colorize`, `git-tag-colorize`, `git-remote-colorize` (parallel, all depend on colorize)
3. `git.zsh` (depends on all three above)
4. `context-badge` (depends on colorize only, parallel with 2–3)

## Testing Decisions

Every modified file gets bats tests. Tests verify observable behavior (output), not internal implementation.

### colorize.bats

File: `config/term/zsh/functions/autoload/misc/__tests__/colorize.bats`

- Without `--zsh`: output contains ANSI sequences (`\e[38;5;...m`, `\e[0m`), no `%F{`
- With `--zsh`: output contains `%F{fg}`, `%K{bg}`, ends with `%f%k`, no `\e[`
- With empty bg: no `%K{` / `\e[48;` in output
- Named color resolved: `colorize text BLUE` uses `$COLOR_BLUE`

### git-branch-colorize.bats

File: `config/term/zsh/functions/autoload/git/branch/__tests__/git-branch-colorize.bats`

- Without `--zsh`: ANSI output, contains branch name
- With `--zsh`: `%F{...}` output, contains branch name
- `--with-icon --zsh`: output contains icon and `%F{`

### git-tag-colorize.bats

File: `config/term/zsh/functions/autoload/git/tag/__tests__/git-tag-colorize.bats`

- Without `--zsh`: ANSI output, contains tag name
- With `--zsh`: `%F{...}` output, contains tag name

### git-remote-colorize.bats

File: `config/term/zsh/functions/autoload/git/remote/__tests__/git-remote-colorize.bats`

- Without `--zsh`: ANSI output, contains remote name
- With `--zsh`: `%F{...}` output, contains remote name

### context-badge.bats (rewrite)

File: `config/term/zsh/functions/autoload/project/__tests__/context-badge.bats`

Inject `PROJECTS` via `typeset -gA PROJECTS; PROJECTS[my-project.path]=...; PROJECTS[my-project.background.ansi]=100; ...` (same pattern as `context-project.bats`).

- Output contains project name for a known path
- Output contains no branch name for the main repo
- Output contains worktree name for a path inside a linked worktree
- Project name argument → same output as project root path argument
- Unknown path → empty output
- Without `--zsh`: ANSI output (`\e[`), no `%K{`
- With `--zsh`: `%K{` output, no `\e[`

## Out of Scope

- All other `*-colorize` functions (`git-date-colorize`, `git-message-colorize`, `docker-*-colorize`, `yarn-*-colorize`, etc.) — no prompt context, no `OROSHI_IS_PROMPT`, not touched
- `git-branch-color`, `git-remote-color` and other color helpers — logic unchanged
- Theming system refactoring (`dist/projects.zsh`, `theming/`) — out of scope
- Updating `CONTEXT.md` (the `PROJECT_<KEY>_*` env var reference is stale but out of scope)
