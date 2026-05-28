## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

A standalone `lua-test-path` script that, given a Lua file path, returns the path to its corresponding spec file if one exists. Mirrors `bats-test-path` exactly:

- If the input already ends with `_spec.lua` and exists → return it as-is
- If the input already ends with `_spec.lua` and does not exist → exit 1
- Otherwise → construct `<dir>/__tests__/<basename>_spec.lua` and return it if the file exists
- If no spec found → exit 1, no output

BATS tests cover all four cases.

## Acceptance criteria

- [ ] Given a `_spec.lua` path that exists, returns the path
- [ ] Given a `_spec.lua` path that does not exist, exits 1 silently
- [ ] Given a source `.lua` file whose `__tests__/<name>_spec.lua` exists, returns the spec path
- [ ] Given a source `.lua` file with no matching spec, exits 1 silently
- [ ] BATS tests cover all four cases

## Blocked by

None — can start immediately
