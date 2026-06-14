## TLDR

Migrate 10 fzf option/preview/source files from `$COLOR_ALIAS_*` / `$COLOR_*` to `$COLORS[key]` via mechanical variable substitution.

## What to build

For each file below, replace every legacy color variable with its `$COLORS` equivalent and
add `colors-load-definitions` if not already present. The mapping is: `COLOR_ALIAS_X` →
`COLORS[x]` (lowercase, underscores become hyphens). Basic colors follow the same pattern:
`COLOR_BLACK` → `COLORS[black]`, `COLOR_WHITE` → `COLORS[white]`, etc.

Files to migrate:

**commands**
- `fzf-commands-options`: `COLOR_ALIAS_FUNCTION`, `COLOR_ALIAS_TEXT`, `COLOR_BLACK`, `COLOR_ALIAS_TERMINAL`, `COLOR_ALIAS_HEADER`

**regexp**
- `fzf-regexp-shared-options`: `COLOR_ALIAS_REGEXP`, `COLOR_ALIAS_DIRECTORY`

**packages-apt** (options and preview only — source-generate is issue 03)
- `fzf-packages-apt-options`: `COLOR_BLACK`, `COLOR_ALIAS_PACKAGE`, `COLOR_ALIAS_TERMINAL`
- `fzf-packages-apt-preview`: `COLOR_ALIAS_FUNCTION`, `COLOR_ALIAS_SUCCESS`, `COLOR_ALIAS_COMMENT`

**claude-sessions**
- `fzf-claude-sessions-options`: `COLOR_GRAY_2`, `COLOR_ALIAS_AI`, `COLOR_ALIAS_TERMINAL`
- `fzf-claude-sessions-preview`: `COLOR_GREEN`, `COLOR_ALIAS_DATE`, `COLOR_ALIAS_COMMENT`
- `fzf-claude-sessions-source-no-query`: `COLOR_ALIAS_COMMENT`

**bats**
- `fzf-bats-test-options`: `COLOR_BLACK`, `COLOR_ALIAS_LANGUAGE_BATS`, `COLOR_ALIAS_TERMINAL`

**docker**
- `fzf-docker-images-remote-options`: `COLOR_WHITE`, `COLOR_ALIAS_DOCKER_IMAGE_REMOTE`, `COLOR_ALIAS_TERMINAL`

**fs**
- `fzf-fs-shared-preview-header`: `COLOR_ALIAS_EXECUTABLE` only (`colors-load-definitions` already present)

## Acceptance criteria

- [ ] All 10 files use no `$COLOR_ALIAS_*` or `$COLOR_*` variables
- [ ] Every file that didn't already have `colors-load-definitions` now calls it before any `$COLORS[...]` reference
- [ ] `zsh-lint` passes on all modified files
- [ ] Opening each affected picker renders the prompt with correct semantic colors
