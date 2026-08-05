## TLDR

Add missing doc comments to all existing autoloaded functions that weren't touched by previous issues.

## What to build

Scan all autoloaded functions in `tools/term/zsh/config/functions/autoload/` and add missing `# Description` comments on line 1.

Scope:
- Only callable functions (not `__lib/`, `__rules/`, fixture files)
- Skip functions already touched by domain issues 04–16
- 537 autoloaded functions total, many already documented — audit to find the gaps

Approach: run `zsh-lint` on the entire autoload directory to find all `missingDocComment` violations, then fix them.

## Acceptance criteria

- [ ] All autoloaded functions have `# Description` on line 1
- [ ] `zsh-lint` reports zero `missingDocComment` violations across autoloaded functions
- [ ] No existing comments were removed or modified
