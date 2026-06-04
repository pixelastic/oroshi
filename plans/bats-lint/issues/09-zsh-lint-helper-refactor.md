## TLDR

Refactor `zsh-lint-shellcheck` and `zsh-lint-custom` into sourceable `.zsh` helper files (function + guard), mirroring the pattern established for `bats-lint` in issue 04.

## Prior art

- `scripts/bin/term/bats/bats-lint/bats-lint-shellcheck.zsh` — guard + function, no shebang
- `scripts/bin/term/bats/bats-lint/bats-lint-custom.zsh` — captures `_zshLintRulesDir="${0:A:h}/__rules"` before the guard, uses it inside the function
- `scripts/bin/term/bats/bats-lint/__tests__/bats-lint-custom.bats` — `bats_run_function` + minimal `mock.zsh` (just `source '...'`)
- `scripts/bin/term/bats/bats-lint/__tests__/bats-lint.bats` — `bats_mock` to mock sub-linters in orchestrator tests

## What to build

**`zsh-lint-shellcheck.zsh`** — extract logic from `zsh-lint-shellcheck` into a function named `zsh-lint-shellcheck()` with guard `whence zsh-lint-shellcheck >/dev/null && return 0`. No shebang, not executable.

**`zsh-lint-custom.zsh`** — extract logic from `zsh-lint-custom`. Capture `_zshLintRulesDir="${0:A:h}/__rules"` **before** the guard (so the guard can short-circuit without side effects). Function uses `$_zshLintRulesDir` to source rule files. No shebang, not executable.

**Delete `zsh-lint-shellcheck` and `zsh-lint-custom`** — executables must be removed so `whence` only matches the function (not an external command), preventing infinite recursion.

**`zsh-lint`** — update orchestrator to source the `.zsh` files and call functions directly instead of running executables via process substitution. Remove `ZSH_LINT_SC` / `ZSH_LINT_CUSTOM` env var overrides (replaced by the function guard pattern).

## Behavioral Tests

**`__tests__/zsh-lint-shellcheck.bats`** — migrate from `bats_run_script "$ZSH_LINT_SC"` to `bats_run_function zsh-lint-shellcheck` + `mock.zsh` that sources `zsh-lint-shellcheck.zsh`

**`__tests__/zsh-lint-custom.bats`** — migrate from `bats_run_script "$ZSH_LINT_CUSTOM"` to `bats_run_function zsh-lint-custom` + `mock.zsh` that sources `zsh-lint-custom.zsh`

**`__tests__/zsh-lint.bats`** — migrate orchestrator tests to use `bats_mock` for `zsh-lint-shellcheck` and `zsh-lint-custom` functions

## Acceptance criteria

- [ ] `zsh-lint-shellcheck.zsh` and `zsh-lint-custom.zsh` exist; executables deleted
- [ ] `zsh-lint` sources `.zsh` files and calls functions
- [ ] All `zsh-lint-shellcheck`, `zsh-lint-custom`, and `zsh-lint` tests pass via `bats_run_function`/`bats_mock`
- [ ] No infinite recursion: guard only fires when function is already defined (not from PATH)
- [ ] `zshlint` passes on all modified files

## Watch out

- **Infinite recursion** — same trap as `bats-lint`: if the executable still exists in PATH when the guard runs, `whence funcName` returns true, the function is never defined, calling the function calls the executable → infinite loop. Fix: delete the executables before committing (use `--no-verify` for the transition commit, same as issue 04).
- **`_zshLintRulesDir`** — must be captured **after** the guard check is confirmed NOT to fire (i.e., place it after the guard line), so it doesn't pollute the namespace when the function is already mocked.
