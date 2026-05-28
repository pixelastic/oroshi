## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

A `lua-lint-custom` runner script that sources all rule files from a `__rules/` directory and runs each against the target Lua file, outputting violations in the common `▮`-separated format. Mirrors `zshlint-custom`.

Alongside the runner, implement the first rule: `rule-no-vim-deepcopy` — flags any call to `vim.deepcopy(` and suggests using `F.clone` instead.

BATS tests cover: the runner with the rule active detecting a violation; the runner with a clean file producing no output. The rule itself is also tested in isolation.

## Acceptance criteria

- [ ] `lua-lint-custom <file>` outputs violations from all rules in `__rules/`
- [ ] `rule-no-vim-deepcopy` flags a line containing `vim.deepcopy(` with the correct code and line number
- [ ] `rule-no-vim-deepcopy` produces no output on a file that does not call `vim.deepcopy`
- [ ] BATS test: runner correctly reports the violation from the rule
- [ ] BATS test: runner exits 0 and produces no output on a clean file

## Blocked by

None — can start immediately
