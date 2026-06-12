## TLDR

Guarantee that a mocked function stays mocked at any depth — including subshells and new zsh processes — verified with the `foo → bar → baz` fixture.

## What to build

Extend `tools/term/bats/config/__tests__/helper.bats` with Deep Mocking tests.

Reuse the `foo → bar → baz` fixture from issue 03. For Deep Mocking tests, `baz` is mocked to echo `"mocked"` instead of its real behavior. The test calls `foo` and asserts the output is `"mocked"` — confirming the mock propagated through the entire chain.

Write three variants of this test:
1. `foo` calls `bar` calls `baz` — all in the same zsh process (direct call)
2. `foo` uses `$(bar)` — `bar` runs in a subshell
3. `foo` invokes `bar` as an external PATH command — `bar` spawns a new zsh process

The third variant is the hard case. Implement the necessary changes to `tools/term/bats/config/helper` so that mocks defined via `bats_mock` are visible in new zsh processes spawned within the script under test. The mechanism is an implementation detail — the behavior guarantee is what matters.

Also verify that mock priority holds: when `baz` is both present as a worktree binary and mocked, the mock wins.

## Behavioral Tests

- Mock `baz`, call `foo` directly → output is `"mocked"`
- Mock `baz`, call `foo` via subshell → output is `"mocked"`
- Mock `baz`, call `foo` as external PATH command → output is `"mocked"`
- Mock wins over worktree binary — mocked `baz` takes precedence over the real `baz` from the worktree

## Acceptance criteria

- [ ] All three Deep Mocking scenarios pass in `helper.bats`
- [ ] Mocks are visible in new zsh processes without explicit test author setup
- [ ] Mock priority over worktree binary is verified
