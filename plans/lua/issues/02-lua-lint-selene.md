## TLDR

Wrap the selene binary to output violations in the common `▮`-separated format.

## What to build

A `lua-lint-selene` script that invokes selene on a Lua file and translates its output into `file▮code▮level▮line▮message` lines. Mirrors `zshlint-shellcheck`. BATS tests cover the happy path (violation found, correct format, exit 1) and the clean path (no output, exit 0).

## Acceptance criteria

- [x] `lua-lint-selene <file>` outputs violations in `file▮code▮level▮line▮message` format
- [x] Exit code is 1 when violations are found, 0 when clean
- [x] BATS test: a file with a known selene violation produces the expected violation line
- [x] BATS test: a clean file produces no output and exits 0
