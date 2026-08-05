## TLDR

Add two new zsh-lint rules: `missingDocComment` and `missingScriptJustification`.

## What to build

Two new custom rules in `scripts/bin/zsh/zsh-lint/__rules/`:

### missingDocComment
- For autoloaded functions: error if line 1 is not a `#` comment
- For scripts (files with shebang): error if line 2 is not a `#` comment
- Skip files in `__lib/`, `__rules/`, `__tests/` directories
- Skip bats fixture scripts

### missingScriptJustification
- For ZSH scripts in `scripts/bin/`: error if no `# Script because:` comment on line 3
- Only applies to files with `#!/usr/bin/env zsh` or similar ZSH shebang
- Skip non-ZSH scripts (Ruby, Python, Node — the interpreter IS the justification)
- Skip files in `__lib/`, `__rules/`, `__tests/` directories

Both rules follow the existing pattern in `zsh-lint/__rules/` and integrate with `zsh-lint-custom`.

## Behavioral Tests

**missingDocComment:**
- reports error when autoloaded function has no comment on line 1
- reports error when script has no comment on line 2
- passes when autoloaded function has comment on line 1
- passes when script has comment on line 2
- skips __lib/ files
- skips __rules/ files

**missingScriptJustification:**
- reports error when ZSH script lacks `# Script because:` on line 3
- passes when ZSH script has justification comment
- skips non-ZSH scripts
- skips __lib/ files

## Acceptance criteria

- [ ] `missingDocComment` rule implemented and tested
- [ ] `missingScriptJustification` rule implemented and tested
- [ ] Both rules integrated with `zsh-lint-custom`
- [ ] Existing zsh-lint tests still pass
