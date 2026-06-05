## Guidance

### Context

This PRD introduces `bats_run_zsh`, a unified bats helper that replaces `bats_run_function` and `bats_run_script`.

### Key files

- Bats helper: `tools/term/bats/config/helper`
- `noRunZsh` rule: `scripts/bin/term/bats/bats-lint/__rules/rule-no-run-zsh.zsh`
- `noRunZsh` rule tests: `scripts/bin/term/bats/bats-lint/__rules/__tests__/rule-no-run-zsh.bats`
- ZSH autoload functions directory: `tools/term/zsh/config/functions/autoload/`

### Detection logic

A file path is an autoload function if it resolves (after `realpath`) to a path under `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/`. Otherwise it is a script.

### Worktree scoping mechanism

The bats helper exports `OROSHI_ROOT=$(git rev-parse --show-toplevel)`. `.zshenv` respects this via `${OROSHI_ROOT:-$HOME/.oroshi}`. This pins `fpath` and `PATH` to the current worktree for all ZSH subprocesses.

### Testing commands

- Run a single test file: `bats <filepath>`
- Lint a bats file: `./scripts/bin/term/bats/bats-lint/bats-lint <filepath>`
- Lint all bats files: `find . -name "*.bats" | xargs ./scripts/bin/term/bats/bats-lint/bats-lint`

### Conventions

- `bats_run_zsh` follows the same mock injection pattern as `bats_run_function` and `bats_run_script` (source `$BATS_TMP_DIR/mock.zsh` if it exists)
- Args forwarded via `run zsh -c "$cmd" -- "$@"`
- No direct tests for the helper itself — validated by migration tests passing

## Discoveries

_Append findings here after each issue is completed._

### Issue 04 — Full migration

- Three migration patterns emerged: (A) autoload functions → `CURRENT=$OROSHI_ROOT/tools/.../autoload/<subdir>/<name>` in setup; (B) `bats_run_script` → direct `bats_run_zsh` substitution; (C) library functions loaded via mock.zsh → add `caller.zsh` stub in `BATS_TMP_DIR` that calls `<funcname> "$@"`, then `bats_run_zsh "$CURRENT"`.
- Files in `scripts/bin/` that used `run_zsh_fn` helpers (manual fpath override) can use `bats_run_zsh "$CURRENT"` directly — `$OROSHI_ROOT` pins fpath to the worktree via `.zshenv`.
- `run zsh script_path` (not `run zsh -c`) → `run script_path` (removes redundant `zsh` invocation while avoiding source-mode issues for scripts using `${0:A:h}`).
- Multi-call tests (`run zsh -c 'fn1; fn2'`) → create `$BATS_TMP_DIR/script.zsh` with the commands, then `bats_run_zsh "$script"`.
- Files with no setup() need `bats_tmp_dir` + teardown added when using temp scripts.

### Issue 01 — bats_run_zsh helper

- `zsh -c "..."` always sources `.zshenv` (ZSH non-interactive rule) — no explicit fpath setup needed in the cmd string; autoload functions resolve automatically via the worktree-scoped `OROSHI_ROOT`.
- Guard form must be `[[ "$var" == "" ]] && return 1`, not `[[ -n "$var" ]] || return 1` — zsh-writer standard enforces the `&&` idiom.
- No if/else for branching cmd: use early-return for the autoload branch, fall-through for script.
