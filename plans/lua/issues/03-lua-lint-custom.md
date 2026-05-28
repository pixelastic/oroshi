## TLDR

Add a `lua-lint-custom` runner and the first custom rule: `rule-no-vim-deepcopy`.

## What to build

A `lua-lint-custom` runner script that sources all rule files from a `__rules/` directory and runs each against the target Lua file, outputting violations in `▮`-separated format. Mirrors `zshlint-custom`.

First rule: `rule-no-vim-deepcopy` — flags any call to `vim.deepcopy(` and suggests using `F.clone` instead.

BATS tests cover: rule detects a violation at the correct line; clean file produces no output.

## Acceptance criteria

- [ ] `lua-lint-custom <file>` outputs violations from all rules in `__rules/`
- [ ] `rule-no-vim-deepcopy` flags a line containing `vim.deepcopy(` with code `noVimDeepcopy` and correct line number
- [ ] `rule-no-vim-deepcopy` produces no output on a file without `vim.deepcopy`
- [ ] BATS test: runner reports the violation
- [ ] BATS test: runner exits 0 and produces no output on a clean file
