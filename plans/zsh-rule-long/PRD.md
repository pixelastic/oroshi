## Problem Statement

When writing zsh scripts, command invocations sometimes grow to exceed a readable line length — multiple piped commands, many `--flags`, and long argument values all on one line. An agent running `zsh-lint` on a script has no signal to know it should refactor these lines. There is no existing `zsh-lint` custom rule that detects overly long command lines.

## Solution

Add a new `zsh-lint` custom rule, `commandTooLong`, that flags any command invocation line exceeding 100 characters. The rule message gives an agent enough context to know how to refactor: split on pipe `|`, put each `--flag` on its own line, use `\` for continuation. Non-command lines (comments, conditionals, `local` declarations, assignments) are excluded because they are not meaningfully splittable the same way.

## User Stories

1. As a zsh author, I want `zsh-lint` to flag command lines over 100 chars, so that overly long invocations are caught before review.
2. As an AI agent running `zsh-lint`, I want the error message to include the max threshold and actionable split instructions, so that I know exactly how to refactor the violation.
3. As a zsh author, I want comment lines and variable assignments to be excluded from the rule, so that I don't get false positives on lines that cannot be meaningfully split.
4. As a zsh author, I want lines starting with `[[`, `if`, or `local` to be excluded from the rule, so that conditionals and declarations are not flagged.
5. As a zsh author, I want to be able to disable the rule on a specific line with `# zsh-lint disable: commandTooLong`, so that genuinely unsplittable long commands are not permanently flagged.
6. As a zsh author, I want the rule to be registered alongside the other custom rules, so that it runs automatically as part of `zsh-lint`.

## Implementation Decisions

- **Threshold:** 100 characters per line.
- **Detection:** a line is a violation if `${#line} > 100` AND it does not match any exclusion pattern.
- **Exclusion patterns (applied in order, first match skips the line):**
  - Starts with `#` — comment
  - Starts with `[[` — conditional test
  - Starts with `if` — if statement
  - Starts with `local` — local declaration
  - Starts with `<identifier>=` — variable assignment (bare `var=...`)
- **Error message:** `Command too long (max 100 chars). Try splitting on pipes or arguments.`
- **Rule code identifier:** `commandTooLong`
- **Rule function name:** `zshLintRule_commandTooLong`
- **Output format:** same `file▮code▮error▮lineno▮message` format as all other custom rules.
- **Registration:** source the new rule file and add the function to `lint-custom-run` in the custom rule loader.

## Testing Decisions

A good test exercises the rule's observable behavior: given these input lines, does the rule emit a violation or not? Tests should not assert on implementation details (regex internals, variable names).

**Module tested:** `rule-command-too-long.zsh` (the rule function itself), via bats using the `run_rule` / `expect_rule_violation` / `expect_clean` helpers — same pattern as `rule-single-equals-in-test.bats`.

**The registration file (`zsh-lint-custom.zsh`) is not tested** — config changes are the artifact.

**Test cases:**

Violations (expect flag):
- A command with a pipe that exceeds 100 chars
- A command with multiple `--flags` that exceeds 100 chars
- A command with no pipe and no flags, just long arguments, that exceeds 100 chars

Clean (expect no flag):
- A comment line exceeding 100 chars
- A line starting with `[[` exceeding 100 chars
- A line starting with `if` exceeding 100 chars
- A line starting with `local` exceeding 100 chars
- A bare variable assignment (`var=...`) exceeding 100 chars
- A command line exactly at 100 chars (boundary — not flagged)
- A command line under 100 chars

## Out of Scope

- Detection of long lines inside heredocs.
- Detection of continuation lines (lines preceded by `\`) — these are already being split.
- Auto-fix / suggested rewrite of the long line.
- Configurable threshold (always 100).
- Rules for other languages (JS, bash).

## Further Notes

The smoke test for this rule is `preToolUse-Bash-helper.zsh` line 41 — a `printf ... | json-set ...` invocation of 103 chars. The rule must flag exactly that line and no other line in that file.
