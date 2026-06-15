## TLDR

Add a `missingFiletypesLoad` zsh-lint custom rule that flags any file accessing `$FILETYPES[` without first calling `filetypes-load-definitions`.

## What to build

Create `__rules/rule-missing-filetypes-load.zsh` following the exact structure of
`rule-missing-colors-load.zsh`:

- Function name: `zshLintRule_missingFiletypesLoad`
- Code: `missingFiletypesLoad`
- Trigger: any non-comment line containing `$FILETYPES[` or `${(k)FILETYPES}`
- Skip if: file already contains `filetypes-load-definitions`
- Reports the first trigger line number

Register the rule in `zsh-lint-custom.zsh` — add a `source` line and add the function name
to the `lint-custom-run` call, alongside the existing load-definition rules.

## Behavioral Tests

**No violation cases:**
- File with no `FILETYPES` usage: no violation
- File with `$FILETYPES[` and `filetypes-load-definitions` present: no violation
- `$FILETYPES[` only in a comment line: no violation
- File with `zsh-lint disable=missingFiletypesLoad` above first trigger: no violation

**Violation cases:**
- File with `$FILETYPES[` but no `filetypes-load-definitions`: violation with code `missingFiletypesLoad`
- `${(k)FILETYPES}` without loader: violation
- Violation reported at the first trigger line number

Prior art: `rule-missing-colors-load.bats`, `rule-missing-icons-load.bats`

## Acceptance criteria

- [ ] Rule file created in `__rules/`
- [ ] Rule registered in `zsh-lint-custom.zsh` (both `source` and `lint-custom-run`)
- [ ] Bats tests pass for all pass and fail cases
