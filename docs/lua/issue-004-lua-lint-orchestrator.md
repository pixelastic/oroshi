## PRD

[Lua toolchain PRD](./PRD.md)

## What to build

The `lua-lint` orchestrator: calls `lua-lint-selene` and `lua-lint-custom` on the target file, merges their `▮`-separated violation streams, and serialises the result as a JSON array. Exit code is 1 if any violations were found, 0 if clean. Mirrors `zshlint`.

BATS tests cover: both sub-tools returning violations (JSON contains entries from both); only one sub-tool returning violations (JSON contains those entries, exit 1); neither returning violations (JSON is empty array, exit 0).

## Acceptance criteria

- [ ] `lua-lint <file>` outputs a JSON array of violation objects
- [ ] Exit code is 1 when any violation is found, 0 when clean
- [ ] BATS test: violations from both selene and custom rules appear in the merged output
- [ ] BATS test: only selene violations — JSON contains only those, exit 1
- [ ] BATS test: only custom violations — JSON contains only those, exit 1
- [ ] BATS test: clean file — empty JSON array, exit 0

## Blocked by

- issue-002 (lua-lint-selene)
- issue-003 (lua-lint-custom)
