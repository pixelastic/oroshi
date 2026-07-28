## TLDR

Add zshlint rule `useEchoerr` that flags `echo ... >&2` and suggests `echoerr`.

## What to build

A new lint rule file at `scripts/bin/zsh/zsh-lint/__rules/rule-use-echoerr.zsh` following the existing rule pattern (see `rule-no-or-guard.zsh` as prior art).

The rule function `zshLintRule_useEchoerr`:
- Iterates lines, skips comments (lines starting with `#`)
- Matches regex `echo.*1?>&2` on non-comment lines
- Emits violations with code `useEchoerr` and message: "Use `echoerr` instead of `echo ... >&2`"
- Output format: `file▮useEchoerr▮error▮line▮message`

Register the rule in `scripts/bin/zsh/zsh-lint/zsh-lint-custom.zsh`:
- Add `source` line for the rule file
- Add `zshLintRule_useEchoerr` to the `lint-custom-run` call

## Behavioral Tests

Test file: `scripts/bin/zsh/zsh-lint/__rules/__tests__/rule-use-echoerr.bats`

**violations:**
- "flags echo string >&2"
- "flags echo >&2 string (redirect in middle)"
- "flags echo string 1>&2 (explicit fd)"

**clean cases:**
- "clean — comment line with echo >&2"
- "clean — echo without redirect"
- "clean — non-echo command with >&2"

**line number:**
- "line number is correct"

## Acceptance criteria

- [ ] `echo "x" >&2` flagged as violation
- [ ] `echo >&2 "x"` flagged as violation
- [ ] `echo "x" 1>&2` flagged as violation
- [ ] Comment lines not flagged
- [ ] `echo` without `>&2` not flagged
- [ ] Non-echo commands with `>&2` not flagged (e.g. `some-cmd >&2`)
- [ ] Line numbers accurate
- [ ] Rule registered in `zsh-lint-custom.zsh`
- [ ] All rule tests pass via `bats`
