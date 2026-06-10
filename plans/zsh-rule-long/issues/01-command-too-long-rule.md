## TLDR

Add `commandTooLong` zsh-lint custom rule that flags command invocations exceeding 100 chars.

## What to build

Create a new custom lint rule `zshLintRule_commandTooLong` and its bats test file, then register it in the custom rule loader.

**Rule behavior:**
- Flag any line where `${#line} > 100` AND the line is not excluded
- Exclusions (first match skips the line): starts with `#`, starts with `[[`, starts with `if`, starts with `local`, starts with `<identifier>=` (bare assignment)
- Error message: `Command too long (max 100 chars). Try splitting on pipes or arguments.`
- Code identifier: `commandTooLong`
- Output format: same `file▮code▮error▮lineno▮message` as all other custom rules

**Registration:** source the new rule file and add the function name to `lint-custom-run` in the custom rule loader — same pattern as all existing rules.

**Smoke test:** after registration, running `zsh-lint` on `tools/ai/claude/config/hooks/preToolUse-Bash-helper.zsh` must flag exactly line 41 and no other line.

## Behavioral Tests

**Violations — one test per type:**
- `flags command with pipe exceeding 100 chars` — a single line: `somecommand arg | othercommand --flag1 val1 --flag2 val2` padded to > 100 chars
- `flags command with multiple --flags exceeding 100 chars` — a single line with many `--flag value` pairs
- `flags command with long positional arguments exceeding 100 chars` — a single line with long bare args, no pipe

**Clean — one test with all exclusions together:**
- Input is a multi-line array containing: a comment > 100 chars, a `[[` conditional > 100 chars, an `if` statement > 100 chars, a `local` declaration > 100 chars, a `var=value` assignment > 100 chars, a valid command exactly 100 chars, a valid command under 100 chars
- Assert: 0 violations

## Scaffolding Tests

_Skip — issue adds only new behavior._

## Acceptance criteria

- [ ] `bats` passes on the new rule test file
- [ ] `zsh-lint preToolUse-Bash-helper.zsh` flags exactly line 41
- [ ] `bats-lint` passes on the new test file
- [ ] `zsh-lint` passes on the new rule file
