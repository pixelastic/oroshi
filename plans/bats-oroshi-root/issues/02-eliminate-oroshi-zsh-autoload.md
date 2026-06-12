## TLDR

Remove `$OROSHI_ZSH_AUTOLOAD` from the codebase — replace every usage with the explicit `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/...` path.

## What to build

Find every occurrence of `$OROSHI_ZSH_AUTOLOAD` in `.zsh` and `.bats` files.

In production `.zsh` scripts: replace with `$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/...`.

In `.bats` test files, the pattern is `CURRENT="$OROSHI_ZSH_AUTOLOAD/path/to/function"` — replace with `CURRENT="$OROSHI_ROOT/tools/term/zsh/config/functions/autoload/path/to/function"`.

Remove `OROSHI_ZSH_AUTOLOAD` from `zshenv.zsh`. At this point `oroshi-export-zsh-paths` exports nothing useful — remove the function entirely and its call site.

Delete the bats-lint rule `rule-prefer-zsh-autoload` (the rule file and its test file). The lint rule enforced a pattern that no longer exists.

## Scaffolding Tests

After the change, no `.zsh` or `.bats` file in the repo contains a reference to `$OROSHI_ZSH_AUTOLOAD`.

## Acceptance criteria

- [ ] All `$OROSHI_ZSH_AUTOLOAD` usages in `.zsh` and `.bats` files replaced
- [ ] `OROSHI_ZSH_AUTOLOAD` and `oroshi-export-zsh-paths` removed from `zshenv.zsh`
- [ ] `rule-prefer-zsh-autoload` rule file and its test file deleted
- [ ] Full bats test suite passes with no regressions
