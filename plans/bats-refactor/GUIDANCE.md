## Guidance

### Context

This plan migrates all `.bats` test files from the retired `CURRENT` variable convention to the new `bats_run_zsh` single-string API. The `bats_run_zsh` implementation already accepts only a single command string (`zsh -c "$1"`); tests that pass extra arguments are currently broken.

### Testing commands

- Run a single test file: `bats <filepath>`
- Lint a single bats file: `bats-lint <filepath>`
- Always run both after editing a file, before moving to the next.

### File locations

- bats-lint rules: `scripts/bin/term/bats/bats-lint/__rules/`
- `bats_run_zsh` implementation: `tools/term/bats/config/helper` (lines 129–142)
- All test files: `__tests__/*.bats` directories throughout the repo

### Migration rules

**Direct invocation (issue 02):**
- `bats_run_zsh "$CURRENT"` → `bats_run_zsh "script-name"`
- `bats_run_zsh "$CURRENT" arg1 arg2` → `bats_run_zsh "script-name arg1 arg2"`
- Heredoc redirect (`<<<`) stays outside the string
- Remove `CURRENT=` from `setup()`; delete `setup()` if it becomes empty

**Source prefix (issue 03):**
- Rename `CURRENT` to `sourcePrefix`
- Change value to full source expression: `sourcePrefix="source '$BATS_TEST_DIRNAME/../file.zsh'"`
- Call sites: `bats_run_zsh "$sourcePrefix && function-name arg"`

**Temp file elimination (issue 04):**
- Remove `CURRENT=` and the `printf`/`cat` that writes the wrapper
- `bats_run_zsh "$CURRENT" arg1 arg2` → `bats_run_zsh "function-name arg1 arg2"`

**Quoting inside the command string:**
- Args with spaces → wrap in single quotes
- Args with apostrophes → `'text d'\''apostrophe'`
- Variable refs → keep unquoted unless value may contain spaces

### Conventions

- Process files one at a time; run `bats` after each before proceeding
- `setup()` that becomes empty → delete entirely
- `teardown()` that becomes empty → delete entirely
- Do not modify test logic, only the calling convention
- Preserve all existing comments in files

### Prior art

- `tools/term/zsh/config/prompt/__tests__/git.bats` — example of `sourcePrefix` usage
- `tools/term/bats/config/__tests__/helper.bats` — example of already-correct `bats_run_zsh "function-name arg"` style

## Discoveries

(Append findings here after each issue — non-trivial patterns, surprises, edge cases encountered.)
