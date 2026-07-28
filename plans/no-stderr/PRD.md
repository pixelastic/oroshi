## Problem Statement

Raw `>&2` redirections after `echo` are cryptic and scattered across ~42 ZSH files. When an agent generates guard clauses, it naturally writes `echo "Error: ..." >&2` — an ugly, non-semantic pattern. There is no lint rule to catch it, so the pattern keeps spreading.

## Solution

Introduce `echoerr`, a one-liner autoloaded ZSH function that wraps `echo "$@" >&2`. Add a zshlint rule `useEchoerr` that flags `echo ... >&2` and suggests `echoerr` instead. Then fix all existing violations across the codebase.

## User Stories

1. As a developer writing a guard clause, I want to call `echoerr "missing argument"` instead of `echo "missing argument" >&2`, so that the intent is explicit and readable
2. As a developer running `zsh-lint`, I want `echo ... >&2` flagged as a violation with a clear fix suggestion, so that I never introduce the raw pattern
3. As a developer touching an old file, I want pre-existing `echo ... >&2` caught by lint-staged, so that violations are cleaned up progressively
4. As a developer reading code, I want to see `echoerr` and immediately understand "this is an error message on stderr", so that I don't have to parse `>&2` mentally
5. As a developer using `echoerr`, I want to pass any flag that `echo` accepts (like `-n`), so that the wrapper is fully transparent
6. As a developer, I want `echoerr` autoloaded (not sourced at shell startup), so that shell startup cost is zero until first use
7. As a developer writing PDF helpers that use process substitution (`2> >(\grep ... >&2)`), I want the rule to NOT flag my code, so that I don't get false positives
8. As a developer, I want to be able to disable the rule with `# zsh-lint disable=useEchoerr` on the rare file that legitimately needs raw `>&2`, so that exceptions are explicit

## Implementation Decisions

- **`echoerr` function**: Autoloaded in `misc/echoerr`. Body is `echo "$@" >&2` with a `# zsh-lint disable=useEchoerr` inline. Minimal header (usage comment only, no `setopt err_return` — nothing can fail in an echo)
- **`useEchoerr` lint rule**: Regex `echo.*1?>&2` on non-comment lines. Only catches `echo` — not `print` or `printf` (different args, different future rules if needed). Rule code: `useEchoerr`. Message: "Use `echoerr` instead of `echo ... >&2`"
- **Registration**: Source the rule file and add the function name to the `lint-custom-run` call in `zsh-lint-custom.zsh`
- **Batch fix**: After rule is implemented, lint all ZSH files and replace every `echo ... >&2` with the equivalent `echoerr ...` call. The `echoerr` body itself is the only file with a disable comment
- **No zsh-writer change**: The lint rule is the single source of truth; no duplication in skill conventions

## Testing Decisions

Tests validate external behavior only — output destination and content, not implementation.

**Module 1 — `echoerr` function:**
- Verify output goes to stderr (not stdout)
- Verify flags (e.g. `-n`) pass through transparently
- Prior art: other autoloaded function tests in `tools/term/zsh/config/functions/autoload/*/__tests__/*.bats`

**Module 2 — `useEchoerr` lint rule:**
- Violation: `echo "x" >&2`, `echo >&2 "x"`, `echo "x" 1>&2`
- Clean: comment line, echo without redirect, non-echo command with `>&2`
- Line number accuracy
- Prior art: `scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-no-or-guard.bats`

## Out of Scope

- `print ... >&2` and `printf ... >&2` rules (future work, separate functions `printerr`/`printferr`)
- Process substitution patterns (`2> >(\grep ... >&2)`) — not echo, not caught
- Fixing violations in non-ZSH files (JS, Python, etc.)
- Adding the convention to the `zsh-writer` skill

## Further Notes

The batch fix touches ~42 files. Each replacement is mechanical: strip `>&2` (and `1>&2`), replace `echo` with `echoerr`. The `echo >&2 "msg"` variant (redirect in the middle) needs the redirect removed and `echo` replaced with `echoerr`.
