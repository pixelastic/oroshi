## TLDR

Remove `$ZSH_CONFIG_PATH` from the codebase — replace every usage with the explicit `$OROSHI_ROOT/tools/term/zsh/config/...` path.

## What to build

Find every occurrence of `$ZSH_CONFIG_PATH` in `.zsh` files. Replace each with `$OROSHI_ROOT/tools/term/zsh/config/` followed by the relative suffix that was already present.

Remove the variable definition from `zshenv.zsh`. The `oroshi-export-zsh-paths` function derives both `ZSH_CONFIG_PATH` and `OROSHI_ZSH_AUTOLOAD` — if `OROSHI_ZSH_AUTOLOAD` is handled in issue 02, remove `ZSH_CONFIG_PATH` from that function now and let the rest follow in 02.

Delete any bats-lint rule that enforces the use of `$ZSH_CONFIG_PATH`. Delete any `.bats` test that specifically asserts `ZSH_CONFIG_PATH` is set to a certain value (the variable no longer exists, so the test has no subject).

Note: `theming/index.zsh` uses `ZSH_CONFIG_PATH` inside a function body where `${0:A:h}` would not work — use `$OROSHI_ROOT/tools/term/zsh/config/...` there too.

## Scaffolding Tests

After the change, no `.zsh` file in the repo contains a reference to `$ZSH_CONFIG_PATH`.

## Acceptance criteria

- [ ] All `$ZSH_CONFIG_PATH` usages in `.zsh` files replaced with `$OROSHI_ROOT/tools/term/zsh/config/...`
- [ ] `ZSH_CONFIG_PATH` removed from `zshenv.zsh`
- [ ] Any bats-lint rule enforcing `$ZSH_CONFIG_PATH` deleted
- [ ] Any `.bats` test asserting `ZSH_CONFIG_PATH` is set deleted or updated
- [ ] Full bats test suite passes with no regressions
