## Execution order

0001 → start here, no blockers (first Custom Rule — tracer bullet)
0002 → needs 0001 (Orchestrator scaffold)
0003 → needs 0002 (independent of 0004–0008)
0004 → needs 0002 (independent of 0003, 0005–0008)
0005 → needs 0002 (independent of 0003–0004, 0006–0008)
0006 → needs 0002 (independent of 0003–0005, 0007–0008)
0007 → needs 0002 (independent of 0003–0006, 0008)
0008 → needs 0002 (independent of 0003–0007)

## Guidance

- **Read CONTEXT.md first** — `docs/zshlint/CONTEXT.md` defines the shared vocabulary (Custom Rule, Lib File, Orchestrator, Rule Output format). Use these terms throughout.
- **Start every rule issue with `grill-with-docs`** — before writing any code for a Custom Rule, run a grill-with-docs session to validate edge cases with the user.
- **Rule Output format**: `file▮code▮level▮line▮message` (▮ = U+25AE). One line per violation, empty output = no violation.
- **Lib File location**: `scripts/bin/zsh/zshlint/__rules/rule-{slug}.zsh`
- **Function naming**: `zshlintRule_{CamelCaseName}()`
- **Test file location**: `scripts/bin/zsh/zshlint/__tests__/rule-{slug}.bats`
- **Test helper**: load with `load '../../../__tests__/helper'` (relative path from `__tests__/` to `scripts/bin/__tests__/helper`)
- **Use `zsh-writer` skill** when writing ZSH code
- **Run `zshlint` on every file you write** — the linter must pass on its own source files

---

## Log (append below when an issue is completed)

## Session 2026-05-19 — 0001: Rule: no manual arg parsing
- Completed: Created directory scaffold (`zshlint/` dir, `__rules/`, `__tests__/`), moved orchestrator file inside. After grill-with-docs session, rule redesigned from `noShift` to `noManualArgParsing`: detects `case "$1"` and `while getopts` patterns instead. Created `rule-no-manual-arg-parsing.zsh`, `rule-no-manual-arg-parsing.bats`, and `__tests__/helper.bash` (shared DSL helpers for all rule tests).
- Tests added: flags `case "$1"`; flags `while getopts`; clean zparseopts file; no false-positive on comment; no false-positive on `case "$2"`
- Discovered: `zshlint` was a flat file — converted to directory as prerequisite. SC2016 is a systematic false positive in rule files using regex patterns with `$` — disable at file header level. New test helper DSL (`run_rule` / `expect_violation` / `expect_clean`) required by user for readability.
- Fixed: none
- Skipped feedback: review noted files are untracked — ralph does not commit, that is the user's job
- Next: 0002 — Orchestrator scaffold (refactor zshlint script to source Lib Files, merge custom + shellcheck JSON output)
