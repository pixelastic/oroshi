## Problem Statement

Claude (the AI) systematically adds defensive `2>/dev/null || true` guards inside `$(...)` command substitutions in ZSH code. With `setopt err_return`, `local var="$(failing-cmd)"` never triggers an abort because `local` itself always returns 0 — making `|| true` redundant. And `2>/dev/null` silences nothing when the called function never writes to stderr.

## Solution

Two complementary fixes:

1. A new `zsh-lint` rule that flags `|| true` inside `$(...)` on `local` assignment lines.
2. A `zsh-writer` skill documentation update explaining when `2>/dev/null` is appropriate inside command substitutions.

## User Stories

1. As a developer running `zsh-lint`, I want to be told when `|| true` inside a `$(...)` on a `local` line is redundant, so that I can remove cargo-cult guards.
2. As a developer, I want to disable the rule per-line or per-file with a `# zsh-lint disable=noLocalSubshellGuard` comment, so that I can suppress false positives.
3. As Claude (AI), I want the `zsh-writer` skill to tell me not to add `2>/dev/null` unless the command writes to stderr, so that I stop adding it by default.
4. As a developer, I want the lint error message to explain why the pattern is wrong, so that I can understand the fix without looking up ZSH semantics.

## Implementation Decisions

- **New rule, not an extension** of `rule-local-or-return`. The existing rule detects guards outside the subshell (`local x=$(cmd) || return`); this rule detects guards inside (`local x="$(cmd || true)"`). Different patterns, different regexes, different messages.
- **`local` only** — `typeset`/`readonly`/`declare`/`export` also mask exit codes but are not used in this codebase's style.
- **`|| true` only** — not `|| :` or other truthy guards. Expand later if needed.
- **Line-by-line only** — no multi-line state tracking. Matches existing rule architecture. The one multiline instance in the codebase is an acceptable miss.
- **`2>/dev/null` handled via skill doc, not lint** — whether stderr suppression is useful depends on what the command does at runtime. Static analysis cannot determine this, so a skill guidance note is the right tool.
- **Error message:** `local masks exit code of $(); remove || true`

## Testing Decisions

- Tests use BATS with the `rules-helper` library, matching all other rule tests.
- Good tests check: violation detected, violation on correct line, clean pass for non-matching patterns, skip comments.
- Test cases:
  - Flag: `local x="$(cmd || true)"` — basic case
  - Flag: `local x="$(cmd 2>/dev/null || true)"` — combined pattern
  - Clean: `local x="$(cmd)"` — no guard
  - Clean: `x="$(cmd || true)"` — bare assignment (guard is needed)
  - Clean: `# local x="$(cmd || true)"` — comment line
  - Clean: `local x="yes || true"` — `|| true` in a literal string, not in `$(...)`
- Prior art: `rule-local-or-return.bats`

## Out of Scope

- Linting `2>/dev/null` inside command substitutions (too context-dependent)
- Multi-line command substitution detection
- Other builtins besides `local`
- Other guard patterns besides `|| true`
- Fixing existing violations in the codebase (zero current instances of the flagged pattern)

## Further Notes

The codebase audit found only 1 instance of `2>/dev/null` inside `$(...)` (in `ctrl-shift-y.zsh`, legitimately suppressing `kitty-remote` errors) and 1 instance of `|| true` inside `$(...)` (in `zsh-lint-shellcheck.zsh`, which is multiline and out of scope). The rule is primarily preventive — stopping Claude from introducing the pattern in future code.
