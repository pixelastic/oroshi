## Guidance

- Testing ZSH: `bats <filepath>`
- Linting ZSH: `zsh-lint <filepath>`
- Linting BATS: `bats-lint <filepath>`
- Tests live in `scripts/bin/fzf/__tests__/`
- Existing tests: `scripts/bin/fzf/__tests__/ctrl-r.bats`
- FZF dispatch system: `scripts/bin/fzf/__lib/init.zsh`
- Domain glossary: `scripts/bin/fzf/GLOSSARY-ctrl-r.md` (terms: Eager, Lazy, History diff, Cache, Mutex)
- FZF glossary: `scripts/bin/fzf/GLOSSARY.md` (terms: Lifecycle Functions, fzf-dispatch, FZF Helpers)
- Use `bats_run_zsh` to run commands in tests, `bats_mock_env` for env overrides
- All test variables go inside `setup()`, not at file top level
- Use `[[ $flag == "1" ]]` not `(( flag ))` for flag tests
- Use `local var="$(cmd)"` pattern for variable assignment
- Source highlighting deps unconditionally — no `|| true`, no availability checks
- The `--no-dispatch` flag (issue 01) must be added to `init.zsh` before ctrl-r tests can call internal functions

## Discoveries

### Issue 02 — ctrl-r refactor
- `aliases/index.zsh` aliases `cat` to `better-cat`; use `command cat` in scripts that source aliases
- `aliases/index.zsh` has `unalias` commands in CLAUDECODE block that fail under `set -e`; mock `CLAUDECODE=""` in bats tests
- `tail -n` triggers zshlint `noDashN` rule; use `tail --lines` instead

### Issue 03 — default postprocess
- To test init.zsh's default fzf-postprocess without any script override, source init.zsh directly: `source $(dirname $(which ctrl-o))/__lib/init.zsh`
- init.bats setup still uses pre-refactor cache paths (`ctrl-r.cache`, `ctrl-r.meta`); those 3 tests (1, 3, 4) are pre-existing failures unrelated to this issue
