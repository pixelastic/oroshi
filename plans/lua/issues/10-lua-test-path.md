## TLDR

`lua-test-path` resolves a Lua source file to its `_spec.lua` counterpart.

## What to build

A standalone `lua-test-path` script mirroring `bats-test-path` exactly:

- Input is a `_spec.lua` file that exists → return it as-is
- Input is a `_spec.lua` file that does not exist → exit 1
- Input is a source `.lua` file → construct `<dir>/__tests__/<basename>_spec.lua` and return it if it exists
- No spec found → exit 1, no output

BATS tests cover all four cases plus the no-argument case.

## Acceptance criteria

- [x] Given a `_spec.lua` path that exists, returns the path
- [x] Given a `_spec.lua` path that does not exist, exits 1 silently
- [x] Given a source `.lua` file whose spec exists, returns the spec path
- [x] Given a source `.lua` file with no spec, exits 1 silently
- [x] BATS tests cover all cases including no arguments
