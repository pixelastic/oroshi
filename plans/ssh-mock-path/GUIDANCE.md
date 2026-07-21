## Guidance

- Test SSH mock: `bats tools/basics/ssh/mock/__tests__/mock.bats`
- Test bats helper: `bats tools/term/bats/config/__tests__/helper.bats`
- Test default teardown: `bats tools/term/bats/config/__tests__/helper-default-teardown.bats`
- Lint zsh: `zsh-lint <filepath>`
- Lint bats: `bats-lint <filepath>`
- Only touch the 5 files listed in the issue — other `/tmp/oroshi` references are unrelated
- Hardcode `/tmp/sandbox` — no env var
- Container name is `ssh-mock` — no prefix

## Discoveries
