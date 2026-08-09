## TLDR

New `zsh-lint` rule flagging redundant `|| true` inside `$(...)` on `local` lines.

## What to build

A lint rule `zshLintRule_noLocalSubshellGuard` that scans each line of a ZSH file and reports a violation when:
- The line starts with `local` (ignoring leading whitespace)
- The line contains a `$(...)` command substitution
- Inside that `$(...)`, there is `|| true`

The rule outputs violations in the standard `▮`-separated format with code `noLocalSubshellGuard` and message `local masks exit code of $(); remove || true`.

Register the rule in `scripts/bin/zsh/zsh-lint/zsh-lint-custom.zsh` — source the file and add the function name to the `lint-custom-run` call.

Prior art: `rule-local-or-return.zsh` (same structure, similar pattern).

## Behavioral Tests

**Violations:**
- flags `local x="$(cmd || true)"`
- flags `local x="$(cmd 2>/dev/null || true)"` (combined pattern)
- reports correct line number

**Clean passes:**
- `local x="$(cmd)"` — no guard
- `x="$(cmd || true)"` — bare assignment, guard is needed
- `# local x="$(cmd || true)"` — comment line
- `local x="yes || true"` — literal string, not inside `$(...)`

## Acceptance criteria

- [ ] Rule file created at `scripts/bin/zsh/zsh-lint/__rules/rule-no-local-subshell-guard.zsh`
- [ ] Rule registered in `zsh-lint-custom.zsh`
- [ ] All BATS tests pass
- [ ] `bats-lint` passes on the test file
- [ ] `zsh-lint` passes on the rule file
