## TLDR

Wire `git-file-lint`, `lint-bats`, and `lintstaged.config.js` to use `is-bats` so extensionless BATS helpers are linted in all three contexts.

## What to build

**`git-file-lint`:** Replace the raw `*.bats` glob check in the file-routing loop with a call to `is-bats` (receiving the full absolute path, same pattern as the existing `is-zsh` call). Add one regression test: creates an extensionless file with a `ft=bats` modeline, marks it dirty in git, and verifies `git-file-lint` routes it to bats-lint. Mock `is-bats` via `bats_mock` to keep the test focused on routing logic, not detection logic.

**`lint-bats` yarn script:** Replace the inner `*.bats` glob filter with a call to `is-bats`. Since the script is invoked by zsh (which sources `.zshenv` and sets up `fpath`), the autoloaded `is-bats` function is available without additional bootstrapping.

**`lintstaged.config.js`:** Replace the `'**/*.bats'` entry with `'{**/*.bats,tools/term/bats/config/*}'`. The broader glob passes matching staged files to `lint:bats`; `is-bats` inside `lint-bats` acts as the authoritative filter. The existing `'tools/**/*': ['yarn run lint:zsh']` entry also matches these paths — acceptable because `lint:zsh` is a no-op on non-zsh files.

## Behavioral Tests

**`git-file-lint` — extensionless bats routing**
- surfaces bats violations for a dirty extensionless file when `is-bats` returns true for it
- does not lint files that `is-bats` rejects (is-bats returns false)

## Acceptance criteria

- [ ] `git-file-lint` calls `is-bats` instead of glob-matching `*.bats`
- [ ] Regression test for extensionless bats routing passes
- [ ] `lint-bats` script calls `is-bats` instead of glob-matching `*.bats`
- [ ] `lintstaged.config.js` entry updated to `'{**/*.bats,tools/term/bats/config/*}'`
- [ ] Modifying `helper` or `rules-helper` triggers `lint:bats` in lint-staged
- [ ] All existing `git-file-lint` tests still pass
