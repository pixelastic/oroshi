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
