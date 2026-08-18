## TLDR

Add conditional `rtk bin-zsh` prefix to each sub-command in `git-file-test` when running inside Claude.

## What to build

In `tools/term/zsh/config/functions/autoload/git/file/git-file-test`:

- At the top (after `setopt`), check `is-claude` once and set an array prefix variable: empty when outside Claude, `(rtk bin-zsh)` when inside.
- Prefix the three sub-command invocations (`yarn run test`, `python-test`, `bats`) with the prefix variable.

In `tools/term/zsh/config/functions/autoload/git/file/__tests__/git-file-test.bats`:

- Add `is-claude() { return 1; }` + `bats_mock is-claude` to `setup()` so all existing tests default to non-Claude context.
- Add new tests (one per runner) that mock `is-claude` returning 0 and mock `rtk` to verify the prefix is applied.

## Behavioral Tests

**Claude context — bats:**
- "prefixes bats with rtk bin-zsh when is-claude"

**Claude context — JS:**
- "prefixes yarn run test with rtk bin-zsh when is-claude"

**Claude context — Python:**
- "prefixes python-test with rtk bin-zsh when is-claude"

## Acceptance criteria

- [ ] `git-file-test` prefixes each sub-command with `rtk bin-zsh` when `is-claude` returns 0
- [ ] `git-file-test` runs sub-commands without prefix when `is-claude` returns 1
- [ ] All existing tests pass unchanged (guarded by `is-claude` mock in `setup()`)
- [ ] New tests verify RTK prefix for bats, yarn, and python-test under Claude context
