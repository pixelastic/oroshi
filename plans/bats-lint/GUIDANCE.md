## Guidance

### Goal

Build `bats-lint`: a linter for `.bats` test files that mirrors the architecture of `zshlint`. The first custom rule flags `run zsh` usage and directs the author to use `bats_run_function` instead.

### Commands

- **Run a BATS test file:** `rtk bats <filepath>`
- **Run ZSH lint:** `zshlint <filepath>`
- **Run BATS lint (once built):** `bats-lint <filepath>`

### File locations

- New linter lives in: `scripts/bin/term/bats/bats-lint/`
- Custom rules in: `scripts/bin/term/bats/bats-lint/__rules/`
- Rule unit tests in: `scripts/bin/term/bats/bats-lint/__rules/__tests__/`
- Orchestrator tests in: `scripts/bin/term/bats/bats-lint/__tests__/`
- lint-staged wrapper: `scripts/yarn/lint-bats`
- lint-staged config: `lintstaged.config.js`
- git-file-lint function: `tools/term/zsh/config/functions/autoload/git/file/git-file-lint`

### Prior art

- **zshlint** (`scripts/bin/zsh/zshlint/`) — mirror this architecture exactly
- **zshlint custom rules** (`scripts/bin/zsh/zshlint/__rules/`) — same rule format (`▮`-delimited output)
- **rules-helper** (`tools/term/bats/config/rules-helper`) — reuse as-is for rule unit tests (`run_rule`, `expect_rule_violation`)
- **lint-zsh wrapper** (`scripts/yarn/lint-zsh`) — mirror for `lint-bats`
- **git-file-lint tests** (`tools/term/zsh/config/functions/autoload/git/file/__tests__/`) — prior art for issue 05

### Conventions

- Rule codes are camelCase (e.g. `noRunZsh`)
- Per-line disable: `# bats-lint-disable <code>`
- JSON output format: `[{ "file": "...", "line": N, "col": N, "code": "...", "message": "..." }]`
- ShellCheck flag: `--shell=bash` (BATS files have `#!/usr/bin/env bats`, not a bash shebang)
- All ZSH files must pass `zshlint` — fix pre-existing violations in any file touched

### Testing

- Rule unit tests use the existing `rules-helper` library (no modification needed)
- Load with `bats_load_library 'helper'` and `bats_load_library 'rules-helper'`
- Tests live in `__tests__/` directories adjacent to the code

## Discoveries

<!-- Agents: append non-trivial findings after each issue below -->
