## Guidance

### Goal

Build `bats-lint`: a linter for `.bats` test files that mirrors the architecture of `zshlint`. The first custom rule flags `run zsh` usage and directs the author to use `bats_run_function` instead.

### Commands

- **Run a BATS test file:** `bats <filepath>`
- **Run ZSH lint:** `zsh-lint <filepath>`
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

### Issue 09 — zsh-lint-helper-refactor

- The spec contradicts itself on `_zshLintRulesDir` placement: "What to build" says **before** the guard; "Watch out" says **after**. The correct placement is **after** the guard — matches the bats-lint prior art (`bats-lint-custom.zsh` line 11) and prevents namespace pollution when the function is already mocked.
- `local` at script scope in orchestrator scripts is correct and required — `zsh-writer/references/variables.md` explicitly says "Use `local` for all variables, even if not in a function."
- `mock.zsh` created in `setup()` is NOT dead code — `bats_run_function` reads it automatically to source the function under test.

### Issue 03 — bats-lint-shellcheck

- ShellCheck messages can contain shell metacharacters (e.g. `$(..)` in SC1072: "Expected end of $(..) expression."). Using `<<< '$output'` in bats tests fails when `$output` contains such strings — bats expands `$output` inside the double-quoted `run bash -c "..."` argument. Use a violation with a safe message (e.g. SC2086 from `echo $HOME`) for format-checking tests; reserve syntax-error fixtures for "detects violation" tests only.
- ShellCheck `--format=json` outputs `column` (not `col`) and `code` as an integer. Transform with `jq -c` (compact) and map `column→col`, `("SC" + (.code|tostring))→code`.
- With `--shell=bash` explicit, SC2148 ("add a shebang") does NOT fire — `--shell` overrides shebang detection entirely. SC2148 is therefore never needed in `excludedRules`; the array starts empty and grows only when real false positives appear.

### Issue 01 — noRunZsh rule

- Bats-lint rules use the **same output format as zshlint**: `file▮code▮error▮line▮message`. This matches what `zshlint-custom` parses (`fields[1..4]`) and what NeoVim receives. Do not deviate.
- The spec described `line▮col▮code▮message` (line first) — that would break `expect_rule_violation` which checks `▮N▮` (line surrounded by separators). The zshlint format puts `line` at field 4, always surrounded.
- Bats-lint rule files follow the zshlint rule pattern exactly: `source` + function call, uses `$_SEP` from env, no `setopt` needed.
