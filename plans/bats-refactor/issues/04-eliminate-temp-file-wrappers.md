## TLDR

For 6 test files where `CURRENT` is a generated temp script wrapping a real function, eliminate the wrapper and call the function directly.

## What to build

Migrate the 6 `.bats` files where `setup()` assigns `CURRENT` to a path inside `$BATS_TMP_DIR` and immediately writes a single-line `function-name "$@"` wrapper to that file. This pattern was a workaround for the old `bats_run_zsh` API; it is now obsolete.

For each file:
1. Remove the `CURRENT=` assignment from `setup()`.
2. Remove the `printf`/`cat` line that writes the wrapper content to the file.
3. Replace every `bats_run_zsh "$CURRENT" arg1 arg2` with `bats_run_zsh "function-name arg1 arg2"`, merging arguments into the command string.
4. If `setup()` becomes empty, delete it.
5. Run `bats <filepath>` and confirm it passes before moving to the next file.

**Quoting:** same rules as issue 02. Arguments containing apostrophes use the `'text d'\''apostrophe'` escape.

**Genuinely complex temp scripts:** If a file contains a multi-line temp script (not just the `"$@"` wrapper), keep it as a `local script=` variable inside the test body and source it via `bats_run_zsh "source $script"`. In practice none of the 6 files fall into this category.

The 6 files in scope are:
- `tools/term/zsh/config/functions/__tests__/oroshi-reload-fpath.bats`
- `tools/term/zsh/config/__tests__/path.bats`
- `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-solkan.bats`
- `tools/ai/claude/config/hooks/__tests__/preToolUse-Bash-rtk.bats`
- `scripts/bin/audio/__tests__/wav2txt-openai.bats`
- `scripts/bin/ai/ralph/__tests__/ralph-loop.bats`

## Scaffolding Tests

- None of the 6 files contains a `CURRENT=` assignment.
- None of the 6 files contains a `printf` or `cat` writing to `$BATS_TMP_DIR/caller.zsh`.
- Every `bats_run_zsh` call in migrated files is a direct function invocation string.

## Acceptance criteria

- [ ] All 6 temp-file-wrapper files are migrated
- [ ] `bats <filepath>` passes for every migrated file
- [ ] `bats-lint <filepath>` passes for every migrated file
- [ ] No `CURRENT=` remains in any migrated file
- [ ] No temp wrapper script is generated in `setup()`
