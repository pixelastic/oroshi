## TLDR

Add a new zsh-lint rule: `missingDocComment`.

## What to build

One new custom rule in `scripts/bin/zsh/zsh-lint/__rules/`:

### missingDocComment
- For autoloaded functions: error if line 1 is not a `#` comment
- For scripts (files with shebang): error if line 2 is not a `#` comment
- Skip files in `__lib/`, `__rules/`, `__tests/` directories
- Skip bats fixture scripts

The rule follows the existing pattern in `zsh-lint/__rules/` and integrates with `zsh-lint-custom`.

## Behavioral Tests

- reports error when autoloaded function has no comment on line 1
- reports error when script has no comment on line 2
- passes when autoloaded function has comment on line 1
- passes when script has comment on line 2
- skips __lib/ files
- skips __rules/ files

## Acceptance criteria

- [ ] `missingDocComment` rule implemented and tested
- [ ] Rule integrated with `zsh-lint-custom`
- [ ] Existing zsh-lint tests still pass
