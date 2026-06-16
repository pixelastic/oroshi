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

### Issue 04 — eliminate temp-file wrappers

- **For sourced `.zsh` functions, use `sourcePrefix` — never write to mock.zsh manually.** `sourcePrefix="source 'path/to/file.zsh'"` in setup, then `bats_run_zsh "${sourcePrefix}; fn-name arg"` in tests. When the function also needs env vars set (e.g. `hookDir`), prepend them in the same string: `sourcePrefix="hookDir='...'; source '...'"`. This composes cleanly with `bats_mock` (which sets MOCK_OVERRIDE independently via append).
- **`path.bats` is genuinely complex** — each test builds a different multi-statement script (env vars + source + call + echo). Used `local script="$BATS_TMP_DIR/script.zsh"` per-test + `bats_run_zsh "source $script"`. The spec note "in practice none of the 6 files fall into this category" was incorrect for this file.
- **Scaffolding test must not check for any specific temp filename**: the initial test checked for `caller.zsh` in file content; path.bats still used it as a local variable value. Renamed to `script.zsh` in path.bats to satisfy the scaffold check.

### Issue 02 — migrate direct invocation

- **56 of ~62 files** were in scope; the remainder use CURRENT for source-prefix, run_bare_zsh, or path extraction — those belong to issues 03/04.
- **`export CURRENT=`** (vs bare `CURRENT=`) escaped the removal regex; one file (`icons-load-definitions.bats`) required a manual fix.
- **`scripts/yarn/hooks/`** is NOT in `$PATH` (only `scripts/bin/**/` is). `post-commit` must be called as `$BATS_TEST_DIRNAME/../post-commit`, not by bare name.
- **Double-quoted args** without `$` prefix get single-quoted inside the merged string (`"#FF0000"` → `'#FF0000'`); args starting with `$` stay bare (`"$JSON_FILE"` → `$JSON_FILE`).
- **Empty setup() deletion** leaves a dangling blank line if a section comment precedes the block; fix by collapsing double blank lines.

### Issue 03 — migrate source-prefix

- **Only 4 files** had `CURRENT` pointing to a `.zsh` file — the "~15" estimate was wrong. All other CURRENT= assignments either use `$BATS_TMP_DIR/caller.zsh` (Issue 04 temp files) or no `.zsh` extension (Issue 02 binaries).
- **`run_bare_zsh` call sites** use the same `$sourcePrefix &&` canonical form as `bats_run_zsh`; trailing lone `;` after the prefix is dropped.
- **`bats-lint-custom.bats`** was already migrated before this session — check for pre-migrated files before counting scope.
