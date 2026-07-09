## Guidance

**Goal:** Add RTK filter support for `python-test` so pytest noise (header, passing lines) is stripped when the agent runs tests directly.

**Testing commands**
- Run bats tests: `bats <filepath>`
- Lint zsh: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`

**Key file locations** (relative to repo root)
- `tools/ai/rtk/config/filters.toml` — RTK filter definitions
- `tools/term/zsh/config/functions/autoload/ai/rtk/rtk-can-rewrite` — pattern recognition function
- `tools/term/zsh/config/functions/autoload/ai/rtk/__tests__/rtk-can-rewrite.bats` — unit tests for pattern recognition
- `tools/ai/rtk/__tests__/rtk.bats` — integration tests for RTK filters

**Conventions**
- `rtk-can-rewrite` uses `[[ "$cmd" =~ '^pattern\b' ]] && return 0` for each pattern
- `filters.toml` uses `match_command` (regex), `strip_ansi`, `strip_lines_matching` (array of regexes), `on_empty`
- Integration tests in `rtk.bats` create real fixture files and run `rtk <command> <file>` end-to-end

**Prior art**
- `[filters.bats]` in `filters.toml` — closest analogue; same strip-passing-lines pattern
- Existing `rtk-can-rewrite.bats` tests for `bats` and `yarn run test` — follow the same structure

## Discoveries

### Issue 01 — Register python-test pattern
- `\b` in ZSH `=~` regex matches word boundaries including before `-` (non-word char), so `^python-test\b` matches `python-test-something`. Use `( |$)` to anchor to space-or-end — same form as the existing `^yarn run test(\b| |$)` pattern.

### Issue 02 — pytest RTK filter
- `python-test` runs pytest without `-v`, so tests show as dots (`test_file.py .  [100%]`), not `PASSED/FAILED` per line. The spec's ` PASSED$` pattern targets verbose mode; add `\[\d+%\]$` to also strip non-verbose progress lines so `on_empty` fires correctly on all-passing runs.
- Both `\[\d+%\]$` and ` PASSED$` are safe to include together — they cover non-verbose and verbose output respectively without conflicting.
