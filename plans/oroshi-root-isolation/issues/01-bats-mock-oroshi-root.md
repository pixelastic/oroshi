## TLDR

Add `bats_mock_oroshi_root` to the bats helper, remove the OROSHI_ROOT pin, and migrate `icons-load-definitions.bats` as proof.

## What to build

Add a `bats_mock_oroshi_root` function to `tools/term/bats/config/helper`. It writes `export OROSHI_ROOT="$1"` into `$BATS_TMP_DIR/mock.zsh` — the same file `bats_mock` uses. It calls `bats_tmp_dir` if `$BATS_TMP_DIR` is empty (same guard as `bats_mock`). The mock persists for the entire `@test` block, cleaned up by `bats_cleanup` in teardown.

Remove the OROSHI_ROOT pin block from the helper (the `export OROSHI_ROOT="$(git rev-parse --show-toplevel)"` and the two derived variables `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD`). The worktree detection in zshenv already handles this: when bats runs from a worktree, `$PWD` is under `$OROSHI_WORKTREES_DIR`, so zshenv detects it and sets `OROSHI_ROOT` to the worktree root.

Migrate `tools/term/zsh/config/functions/autoload/icons/__tests__/icons-load-definitions.bats`:
- Replace `bats_run_function` with `bats_run_zsh` (pass the full path to the autoload function)
- Replace `export OROSHI_ROOT="$BATS_TMP_DIR"` with `bats_mock_oroshi_root "$BATS_TMP_DIR"`

The execution order in the subprocess is: `.zshenv` (builds PATH/fpath) -> `mock.zsh` (overrides OROSHI_ROOT) -> function under test. This is what allows config redirection without breaking autoloaded functions.

## Behavioral Tests

**icons-load-definitions sources config from mock root**
- Given OROSHI_ROOT is mocked to a fake directory containing a minimal `tools/term/zsh/config/theming/icons.zsh`, when `icons-load-definitions` runs, then it sources the file from the mock root

**icons-load-definitions is a no-op when ICONS is already populated**
- Given ICONS associative array is already populated, when `icons-load-definitions` runs, then existing values are preserved (not overwritten by mock root config)

## Acceptance criteria

- [ ] `bats_mock_oroshi_root` exists in the helper and writes to `mock.zsh`
- [ ] OROSHI_ROOT pin removed from the helper (no more `git rev-parse --show-toplevel`)
- [ ] `icons-load-definitions.bats` uses `bats_run_zsh` and `bats_mock_oroshi_root`
- [ ] `bats icons-load-definitions.bats` passes
- [ ] All other existing bats tests still pass (pin removal is non-breaking)
