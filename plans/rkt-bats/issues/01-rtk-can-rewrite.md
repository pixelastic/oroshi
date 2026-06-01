## TLDR

New `rtk-can-rewrite` autoloaded function that checks whether RTK can handle a command — via built-in rewrite or TOML custom filter.

## What to build

A zsh autoloaded function in the `ai/rtk` subdomain. It takes a full command string, exits 0 if RTK can handle it, exits 1 otherwise. No stdout output.

Internally it checks in order: RTK's built-in `rewrite` command first, then falls back to parsing the RTK TOML filters file — extracting `[filters.NAME]` section names and comparing against the first word of the command.

Two env var overrides exist for the function's own test isolation: `RTK_CMD` (rtk binary path) and `RTK_FILTERS_TOML` (filters file path).

Note: a stale test file `hooks/__tests__/rtk-can-rewrite.bats` exists from an earlier draft — delete it and place the real tests alongside the function in the `ai/rtk` subdomain.

## Acceptance criteria

- [ ] Function exists in the `ai/rtk` autoload subdomain
- [ ] `rtk-can-rewrite "git status"` exits 0 (built-in rewrite)
- [ ] `rtk-can-rewrite "bats foo.bats"` exits 0 (TOML filter match)
- [ ] `rtk-can-rewrite "echo hello"` exits 1 (no match)
- [ ] No stdout output in any case
- [ ] Bats tests pass (real RTK, no mocks)
- [ ] `zshlint` clean
