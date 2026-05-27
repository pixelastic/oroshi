## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

A `lua-lint-selene` script that wraps the selene binary and translates its output into the common violation format used by the lua-lint toolchain: one line per violation using the `▮` separator (`file▮code▮level▮line▮message`). Mirrors the role of `zshlint-shellcheck` in the ZSH toolchain.

BATS tests cover the happy path (violation found, correct output format, exit 1) and the clean path (no violations, empty output, exit 0).

## Acceptance criteria

- [ ] `lua-lint-selene <file>` outputs violations in `file▮code▮level▮line▮message` format
- [ ] Exit code is 1 when violations are found, 0 when clean
- [ ] BATS test: a file with a known selene violation produces the expected violation line
- [ ] BATS test: a clean file produces no output and exits 0

## Blocked by

- issue-001 (selene must be installed)
