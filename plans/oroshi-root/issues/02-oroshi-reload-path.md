## TLDR

Extract the PATH-building logic into a persistent, callable `oroshi-reload-path [root]` function.

## What to build

The current `path.zsh` defines `oroshi_path()`, calls it once, then immediately unfunctions it —
making it unreachable after init. Refactor this into a persistent function named `oroshi-reload-path`
(hyphen convention, matching the rest of the codebase) that stays available after first call.

The function accepts an optional `[root]` argument. When provided, it uses that root instead of
`$OROSHI_ROOT` to compute which `scripts/bin/` subdirectories to add to `$PATH`. When omitted,
it falls back to the current `$OROSHI_ROOT`.

Update the call site in `zshenv.zsh` to use the new name. The function must remain defined
after the call (no `unfunction`).

## Behavioral Tests

**Given a non-default root argument:**
- PATH contains the `scripts/bin/` subdirectories of the given root
- PATH does not contain `scripts/bin/` subdirectories from `~/.oroshi`

**Given no argument:**
- PATH contains the `scripts/bin/` subdirectories from the current `$OROSHI_ROOT`

## Scaffolding Tests

- `oroshi_path` (underscore, old name) is not defined after shell init

## Acceptance criteria

- [ ] `oroshi-reload-path` is callable after shell init
- [ ] `oroshi-reload-path <worktree-root>` rebuilds `$PATH` from that root's `scripts/bin/`
- [ ] `oroshi-reload-path` with no args behaves identically to the current `oroshi_path` call
- [ ] `oroshi_path` (old name) no longer exists after init
- [ ] Behavioral tests pass
