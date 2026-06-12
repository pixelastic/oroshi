## TLDR

Guarantee that all binaries resolved during a test run come from the oroshi root that launched `bats` — verified with a `foo → bar → baz` call chain fixture.

## What to build

Create `tools/term/bats/config/__tests__/helper.bats`. This file is the test suite for the helper itself and will grow with issues 04 and 05.

Define the `foo → bar → baz` fixture: three minimal scripts installed as binaries in the test environment. Each script simply delegates to the next in the chain. `baz` echoes the resolved absolute path of its own binary (so the test can assert which root it came from).

Write tests using this fixture to verify Worktree-aware:
- When `bats` is run from the main oroshi root, `baz` resolves from `~/.oroshi`
- When `bats` is run from a worktree, `foo`, `bar`, and `baz` all resolve from that worktree

Implement the necessary changes to `tools/term/bats/config/helper` so that every subprocess launched by `bats_run_zsh` sees the launcher's oroshi root as `OROSHI_ROOT` by default — without the test author needing to configure anything. The `.zshenv` PWD-based detection must not override this injected value.

## Behavioral Tests

- Calling `foo` (which calls `bar` which calls `baz`) returns a `baz` path inside the current oroshi root
- When run from worktree-toto, `baz` path is inside worktree-toto — not `~/.oroshi`
- All three binaries in the chain resolve from the same root
- No explicit setup is required in the test — worktree-aware is automatic

## Acceptance criteria

- [ ] `tools/term/bats/config/__tests__/helper.bats` created
- [ ] `foo → bar → baz` fixture defined and reusable across subsequent issues
- [ ] Worktree-aware tests pass when run from a worktree
- [ ] Default subprocess `OROSHI_ROOT` equals the launcher's oroshi root
- [ ] No test author setup required to activate Worktree-aware
