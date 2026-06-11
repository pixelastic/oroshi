## TLDR

Support `# zsh-lint disable=rule1,rule2` to suppress multiple rules with a single comment.

## What to build

Extend the shared disable-check logic in `tools/term/zsh/config/functions/autoload/lint/lint-custom-run` to parse a comma-separated list of rule codes from a disable comment, then check membership rather than exact match. Single-rule comments (`disable=rule1`) remain valid — they are just a list of length one.

The check currently lives on a single line (~line 60). Replace it with:
1. Match the disable comment pattern and extract the full code list string
2. Split the list on `,`
3. Suppress the violation if `ruleCode` is a member of the resulting array

No spaces are allowed around commas. Unknown rule codes in the list are silently ignored.

Extend `scripts/bin/zsh/zsh-lint/__tests__/zsh-lint-custom.bats` and `scripts/bin/term/bats/bats-lint/__tests__/bats-lint-custom.bats` with the new behavioral tests (via linter entry points, not `lint-custom-run` directly).

## Behavioral Tests

**Multi-rule disable — zshlint**
- `disable=noGroupedLocals,singleEqualsInTest` suppresses both violations on the next line
- `disable=noGroupedLocals,singleEqualsInTest` does not suppress a third rule that also fires on that line

**Multi-rule disable — batslint**
- `disable=noRunZsh,noInlineFunction` suppresses both violations on the next line
- `disable=noRunZsh,noInlineFunction` does not suppress a third rule that also fires on that line

## Acceptance criteria

- [ ] `# zsh-lint disable=rule1,rule2` suppresses both rule1 and rule2 on the next line
- [ ] `# bats-lint disable=rule1,rule2` suppresses both rule1 and rule2 on the next line
- [ ] A third rule firing on the same line is not suppressed
- [ ] Single-rule format `# zsh-lint disable=rule1` still works (existing tests pass)
- [ ] `zsh-lint` and `bats-lint` test suites pass
