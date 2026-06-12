# BATS Helper

The BATS helper system (`tools/term/bats/config/helper`) provides test infrastructure for oroshi's zsh scripts and autoloaded functions. These three principles define the guarantees it makes to test authors.

## Language

**Worktree-aware**:
The property of the BATS helper ensuring that all binaries (PATH scripts and zsh autoloaded functions) resolved during a test run — at any call depth — come from the oroshi root from which `bats` was launched.
_Avoid_: root-scoped, oroshi-root-aware

**Deep Mocking**:
The guarantee that a function mocked via `bats_mock` overrides the real implementation at any depth in the call chain — including direct calls, subshells (`$()`), and new zsh processes spawned via PATH.
_Avoid_: deep mockability, transitive mocking, recursive mocking

**Root Override**:
The ability to override `OROSHI_ROOT` inside the zsh subprocess launched by `bats_run_zsh`, so code under test reads config and data files from a controlled directory. Does not affect binary resolution, which remains governed by Worktree-aware.
_Avoid_: config-dir override, root mocking, OROSHI_ROOT override

## Relationships

- **Worktree-aware** and **Root Override** are orthogonal — they govern different domains (binaries vs data/config paths)
- **Deep Mocking** applies on top of **Worktree-aware**: a mock always wins over a worktree binary
- A **Root Override** does not interact with **Deep Mocking** — overriding `OROSHI_ROOT` neither enables nor disables mocks

## Flagged ambiguities

- "worktree" implies git worktrees specifically, but **Worktree-aware** applies equally when `bats` is run from main (`~/.oroshi`) — the term is kept because the worktree case is dominant in practice

## Example dialogue

> **Dev:** "I mocked `git-worktree-path` but my test still calls the real one — what's wrong?"
> **Answer:** Check whether the script under test spawns a new zsh process. **Deep Mocking** guarantees the mock is visible there too, but only if the helper is correctly configured — not just if the function is defined in the current shell.

> **Dev:** "I used **Root Override** to point `OROSHI_ROOT` at `/tmp/fake-config`, but now `git-branch-current` isn't found."
> **Answer:** **Root Override** only affects data/config paths. Binary resolution is governed by **Worktree-aware** and is independent — `git-branch-current` should still resolve from the worktree.
