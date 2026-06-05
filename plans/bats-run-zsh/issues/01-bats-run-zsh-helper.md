## TLDR

Add `bats_run_zsh` to the bats helper and deprecate `bats_run_function` / `bats_run_script`.

## What to build

Add a new function `bats_run_zsh` to the bats helper library. It accepts a file path and optional arguments.

The function normalizes the input path to absolute using `realpath`. If normalization fails (file does not exist), it fails immediately.

It then checks whether the resolved path falls under `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/`. If yes, it treats the file as a ZSH autoload function and calls the function by its basename inside a ZSH subprocess — relying on the ZSH autoload mechanism (fpath set up by `.zshenv` from `OROSHI_ROOT`). If no, it treats the file as a script and sources it inside a ZSH subprocess.

In both cases, `$BATS_TMP_DIR/mock.zsh` is sourced first (if it exists) to inject mocks. Arguments are forwarded via the standard `-- "$@"` pattern.

Add deprecation comments to `bats_run_function` and `bats_run_script` pointing to `bats_run_zsh`.

## Behavioral Tests

Skipped — no direct tests for the helper (see PRD testing decisions).

## Acceptance criteria

- [ ] `bats_run_zsh <path-to-autoload-fn>` calls the function by basename in a ZSH subprocess
- [ ] `bats_run_zsh <path-to-script>` sources the script in a ZSH subprocess
- [ ] Relative paths are resolved to absolute before detection
- [ ] Mocks from `bats_mock` are injected in both cases
- [ ] Extra arguments are forwarded correctly in both cases
- [ ] Stdin piped via `<<<` works in both cases
- [ ] `bats_run_function` and `bats_run_script` have deprecation comments
- [ ] `bats-lint` passes on the helper file
